BeforeAll { . (Join-Path (Split-Path $PSScriptRoot -Parent) 'State.ps1') }
Describe 'Write-ahead resource intent' {
    It 'persists identity and pending phase before mutation and recovers it' {
        $path = Join-Path $TestDrive 'intent-state.json'
        Set-ResourceIntent -Path $path -Kind 'account' -Identity 'remotehelp77' -Marker 'test-marker-77'
        $record = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
        $record.Kind | Should -Be 'account'
        $record.Identity | Should -Be 'remotehelp77'
        $record.Marker | Should -Be 'test-marker-77'
        $record.Phase | Should -Be 'pending'
        Set-ResourceApplied -Path $path -Identity 'remotehelp77'
        (Get-Content -LiteralPath $path -Raw | ConvertFrom-Json).Phase | Should -Be 'applied'
    }
    It 'does not mark a different identity as applied' {
        $path = Join-Path $TestDrive 'intent-other.json'
        Set-ResourceIntent -Path $path -Kind 'firewall' -Identity 'rule-one' -Marker 'test-marker-88'
        { Set-ResourceApplied -Path $path -Identity 'rule-two' } | Should -Throw
        (Get-Content -LiteralPath $path -Raw | ConvertFrom-Json).Phase | Should -Be 'pending'
    }
    It 'refuses to overwrite unresolved intent' {
        $path = Join-Path $TestDrive 'intent-conflict.json'
        Set-ResourceIntent -Path $path -Kind 'account' -Identity 'one' -Marker 'test-marker-99'
        { Set-ResourceIntent -Path $path -Kind 'account' -Identity 'two' -Marker 'test-marker-100' } | Should -Throw
        (Get-Content -LiteralPath $path -Raw | ConvertFrom-Json).Identity | Should -Be 'one'
    }
}

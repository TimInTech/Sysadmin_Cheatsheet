BeforeAll { . (Join-Path (Split-Path $PSScriptRoot -Parent) 'State.ps1') }
Describe 'RemoteHelp state replacement' {
    It 'writes and replaces complete JSON without leaving a temporary file' {
        $path = Join-Path $TestDrive 'state.json'
        Write-AtomicState -Path $path -State @{ User='first' }
        Write-AtomicState -Path $path -State @{ User='second'; Id=42 }
        $state = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
        $state.User | Should -Be 'second'
        $state.Id | Should -Be 42
        @(Get-ChildItem $TestDrive).Count | Should -Be 1
    }
    It 'leaves existing state untouched when input validation fails' {
        $path = Join-Path $TestDrive 'state.json'
        Write-AtomicState -Path $path -State @{ User='first' }
        { Write-AtomicState -Path $path -State @{ User='second' } -Depth 0 } | Should -Throw
        (Get-Content -LiteralPath $path -Raw | ConvertFrom-Json).User | Should -Be 'first'
    }
}

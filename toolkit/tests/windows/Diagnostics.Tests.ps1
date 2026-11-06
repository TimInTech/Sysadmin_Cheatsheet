Describe 'Windows diagnostic entry points' {
    BeforeAll {
        $root = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'windows\zusatz'
        $script = Join-Path $root 'DIAGNOSE.ps1'
    }
    It 'parses in Windows PowerShell' {
        $tokens = $null; $errors = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($script, [ref]$tokens, [ref]$errors)
        @($errors).Count | Should -Be 0
    }
    It 'provides a launcher for <name>' -ForEach @(
        @{ name='SYSTEMINFO' }, @{ name='SSH_REPARIEREN' },
        @{ name='WINDOWS_DIAGNOSE' }, @{ name='SYSTEM_REPARIEREN' },
        @{ name='NETZWERK_DIAGNOSE' }
    ) {
        Test-Path (Join-Path $root "$name.cmd") | Should -BeTrue
    }
}

Describe 'System repair confirmation' {
    BeforeAll {
        . (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'windows\zusatz\Repair.ps1')
        function Test-Admin { $true }
        function Invoke-NativeChecked([string]$Program, [string[]]$Arguments) {}
    }
    BeforeEach {
        Mock Test-Admin { $true }
        Mock Invoke-NativeChecked {}
    }
    It 'does not run DISM repair or SFC when confirmation is declined' {
        Mock Read-Host { 'NEIN' }
        Invoke-SystemRepair
        Should -Invoke Invoke-NativeChecked -Times 1 -Exactly
        Should -Invoke Invoke-NativeChecked -Times 0 -ParameterFilter { $Arguments -contains '/RestoreHealth' -or $Program -like '*sfc.exe' }
    }
    It 'does not run SFC if DISM repair fails' {
        Mock Read-Host { 'JA' }
        Mock Invoke-NativeChecked { throw 'DISM failed' } -ParameterFilter { $Arguments -contains '/RestoreHealth' }
        { Invoke-SystemRepair } | Should -Throw
        Should -Invoke Invoke-NativeChecked -Times 0 -ParameterFilter { $Program -like '*sfc.exe' }
    }
    It 'runs repair and SFC after explicit confirmation' {
        Mock Read-Host { 'JA' }
        Invoke-SystemRepair
        Should -Invoke Invoke-NativeChecked -Times 1 -Exactly -ParameterFilter { $Arguments -contains '/RestoreHealth' }
        Should -Invoke Invoke-NativeChecked -Times 1 -Exactly -ParameterFilter { $Program -like '*sfc.exe' }
    }
}

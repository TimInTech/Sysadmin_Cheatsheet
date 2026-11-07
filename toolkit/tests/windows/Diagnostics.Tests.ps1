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

Describe 'Elevation helper' {
    BeforeAll {
        . (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'windows\Gemeinsam.ps1')
    }
    It 'continues without a new window when already elevated' {
        Mock Test-ToolkitAdmin { $true }
        Mock Start-Process {}
        Request-ToolkitAdmin -ScriptPath 'C:\x\y.ps1' | Should -BeTrue
        Should -Invoke Start-Process -Times 0
    }
    It 'starts an elevated copy that keeps its window open' {
        Mock Test-ToolkitAdmin { $false }
        Mock Start-Process {}
        Request-ToolkitAdmin -ScriptPath 'C:\Mein Ordner\y.ps1' -Arguments @('-Stop') | Should -BeFalse
        Should -Invoke Start-Process -Times 1 -Exactly -ParameterFilter {
            $Verb -eq 'RunAs' -and $ArgumentList -contains '-Pause' -and $ArgumentList -contains '-Stop' -and $ArgumentList -contains '"C:\Mein Ordner\y.ps1"'
        }
    }
    It 'explains instead of throwing when the UAC prompt is declined' {
        Mock Test-ToolkitAdmin { $false }
        Mock Start-Process { throw 'Der Vorgang wurde durch den Benutzer abgebrochen.' }
        { Request-ToolkitAdmin -ScriptPath 'C:\x\y.ps1' } | Should -Not -Throw
        Request-ToolkitAdmin -ScriptPath 'C:\x\y.ps1' | Should -BeFalse
    }
}

Describe 'SSH repair' {
    BeforeAll {
        . (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'windows\zusatz\Repair.ps1')
        function Test-Admin { $true }
        function Invoke-TestFix {}
        function New-TestFinding([bool]$Ok, [bool]$Fixable) {
            $fix = $null
            if ($Fixable) { $fix = { Invoke-TestFix } }
            [pscustomobject]@{ Name = 'Test'; Ok = $Ok; Text = 'Testbefund'; Fix = $fix }
        }
    }
    BeforeEach {
        Mock Test-Admin { $true }
        Mock Invoke-TestFix {}
        $script:calls = 0
    }
    It 'changes nothing and does not ask when everything is fine' {
        Mock Get-SshFindings { New-TestFinding $true $false }
        Mock Read-Host { 'JA' }
        Invoke-SshRepair | Should -Be 0
        Should -Invoke Read-Host -Times 0
        Should -Invoke Invoke-TestFix -Times 0
    }
    It 'does not fix anything when confirmation is declined' {
        Mock Get-SshFindings { New-TestFinding $false $true }
        Mock Read-Host { 'nein' }
        Invoke-SshRepair | Should -Be 1
        Should -Invoke Invoke-TestFix -Times 0
    }
    It 'fixes after JA and checks again' {
        Mock Get-SshFindings { $script:calls++; if ($script:calls -eq 1) { New-TestFinding $false $true } else { New-TestFinding $true $false } }
        Mock Read-Host { 'JA' }
        Invoke-SshRepair | Should -Be 0
        Should -Invoke Invoke-TestFix -Times 1 -Exactly
        Should -Invoke Get-SshFindings -Times 2 -Exactly
    }
    It 'does not ask for problems without automatic fix' {
        Mock Get-SshFindings { New-TestFinding $false $false }
        Mock Read-Host { 'JA' }
        Invoke-SshRepair | Should -Be 1
        Should -Invoke Read-Host -Times 0
    }
    It 'stops after two repair rounds if a fix keeps failing' {
        Mock Get-SshFindings { New-TestFinding $false $true }
        Mock Read-Host { 'JA' }
        Mock Invoke-TestFix { throw 'kaputt' }
        Invoke-SshRepair | Should -Be 1
        Should -Invoke Invoke-TestFix -Times 2 -Exactly
        Should -Invoke Get-SshFindings -Times 3 -Exactly
    }
    It 'offers to install OpenSSH and skips dependent checks when it is missing' {
        Mock Get-SshCapabilityState { 'NotPresent' }
        Mock Test-Path { $true }
        $findings = @(Get-SshFindings)
        $findings.Count | Should -Be 1
        $findings[0].Ok | Should -BeFalse
        $findings[0].Fix | Should -Not -BeNullOrEmpty
    }
    It 'reports a stopped and disabled service as fixable problems' {
        Mock Get-SshCapabilityState { 'Installed' }
        Mock Test-Path { param($LiteralPath) $LiteralPath -notlike '*SysadminToolkit-RemoteHelp*' -and $LiteralPath -notlike '*administrators_authorized_keys' }
        Mock Test-SshConfigValid { $true }
        Mock Get-SshServiceInfo { [pscustomobject]@{ StartMode = 'Disabled'; State = 'Stopped' } }
        $problems = @(Get-SshFindings | Where-Object { -not $_.Ok })
        ($problems | ForEach-Object Name) | Should -Be @('Starttyp', 'SSH-Dienst')
        @($problems | Where-Object { -not $_.Fix }).Count | Should -Be 0
    }
    It 'detects leftovers of an aborted START_HIER run' {
        Mock Get-SshCapabilityState { 'Installed' }
        Mock Test-Path { param($LiteralPath) $LiteralPath -notlike '*owner.json' -and $LiteralPath -notlike '*administrators_authorized_keys' }
        Mock Test-SshConfigValid { $true }
        Mock Get-SshServiceInfo { [pscustomobject]@{ StartMode = 'Manual'; State = 'Running' } }
        $left = @(Get-SshFindings | Where-Object { $_.Name -eq 'Toolkit-Reste' })
        $left.Count | Should -Be 1
        $left[0].Fix | Should -Not -BeNullOrEmpty
    }
    It 'judges administrators_authorized_keys like OpenSSH (write rights only for Administrators and SYSTEM)' -Skip:($env:OS -ne 'Windows_NT') {
        $file = Join-Path $TestDrive 'administrators_authorized_keys'
        Set-Content -LiteralPath $file -Value 'ssh-ed25519 AAAA test'
        # The test user holds write rights (explicit entry in the user's temp folder).
        Test-AdminKeysAcl $file | Should -BeFalse
        # The repair must also remove explicit entries, which icacls /inheritance:r keeps.
        Set-AdminKeysAcl $file
        $after = Test-AdminKeysAcl $file
        if (-not $after) { & "$env:WINDIR\System32\icacls.exe" $file | Out-Host }
        $after | Should -BeTrue
        # Read-only access for Users is tolerated by OpenSSH.
        & "$env:WINDIR\System32\icacls.exe" $file /grant '*S-1-5-32-545:R' | Out-Null
        Test-AdminKeysAcl $file | Should -BeTrue
        & "$env:WINDIR\System32\icacls.exe" $file /grant '*S-1-5-32-545:M' | Out-Null
        Test-AdminKeysAcl $file | Should -BeFalse
        (Get-Acl -LiteralPath $file).GetOwner([Security.Principal.SecurityIdentifier]).Value | Should -Be 'S-1-5-32-544'
    }
    It 'builds the admin keys repair as an unbound script block that can call Set-AdminKeysAcl' {
        Mock Get-SshCapabilityState { 'Installed' }
        Mock Test-Path { param($LiteralPath) $LiteralPath -notlike '*SysadminToolkit-RemoteHelp*' }
        Mock Test-SshConfigValid { $true }
        Mock Test-AdminKeysAcl { $false }
        Mock Get-SshServiceInfo { [pscustomobject]@{ StartMode = 'Manual'; State = 'Running' } }
        Mock Set-AdminKeysAcl {}
        $finding = @(Get-SshFindings | Where-Object { $_.Name -eq 'Schluesseldatei der Administratoren' })
        $finding.Count | Should -Be 1
        & $finding[0].Fix
        Should -Invoke Set-AdminKeysAcl -Times 1 -Exactly -ParameterFilter { $Path -like '*\ssh\administrators_authorized_keys' -or $Path -like '*/ssh/administrators_authorized_keys' }
    }
}

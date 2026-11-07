Describe 'SSH starter' {
    BeforeAll { $root = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'windows' }
    It 'parses in Windows PowerShell: <file>' -ForEach @(@{ file='SSH_EINRICHTEN.ps1' }, @{ file='Gemeinsam.ps1' }) {
        $tokens = $null; $errors = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile((Join-Path $root $file), [ref]$tokens, [ref]$errors)
        @($errors).Count | Should -Be 0
    }
    It 'contains only ASCII (Windows PowerShell 5.1 reads BOM-less scripts as ANSI): <file>' -ForEach @(
        @{ file='SSH_EINRICHTEN.ps1' }, @{ file='Gemeinsam.ps1' }, @{ file='Aktualisieren.ps1' },
        @{ file='zusatz\DIAGNOSE.ps1' }, @{ file='zusatz\Repair.ps1' }
    ) {
        $bytes = [IO.File]::ReadAllBytes((Join-Path $root $file))
        @($bytes | Where-Object { $_ -gt 127 }).Count | Should -Be 0
    }
    It 'copies its helper file for the scheduled stop task' {
        $text = Get-Content -LiteralPath (Join-Path $root 'SSH_EINRICHTEN.ps1') -Raw
        $text | Should -Match "Copy-Item -LiteralPath \`$common -Destination \(Join-Path \`$folder 'Gemeinsam.ps1'\)"
    }
    It 'update script parses in Windows PowerShell' {
        $tokens = $null; $errors = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile((Join-Path $root 'Aktualisieren.ps1'), [ref]$tokens, [ref]$errors)
        @($errors).Count | Should -Be 0
        Test-Path (Join-Path $root 'WINDOWS_AKTUALISIEREN.cmd') | Should -BeTrue
    }
    It 'has both local starter files' {
        Test-Path (Join-Path $root 'START_HIER.cmd') | Should -BeTrue
        Test-Path (Join-Path $root 'STOP_HIER.cmd') | Should -BeTrue
    }
    It 'limits password access to the selected subnet in OpenSSH' -Skip:($env:OS -ne 'Windows_NT') {
        $ssh = "$env:WINDIR\System32\OpenSSH\sshd.exe"
        $key = Join-Path $TestDrive 'host_key'
        $process = Start-Process "$env:WINDIR\System32\OpenSSH\ssh-keygen.exe" -ArgumentList "-q -t ed25519 -N `"`" -f `"$key`"" -NoNewWindow -PassThru
        $null = $process.Handle
        if (-not $process.WaitForExit(15000)) { $process.Kill(); throw 'ssh-keygen timeout' }
        if ($process.ExitCode -ne 0) { throw 'ssh-keygen failed' }
        $config = Join-Path $TestDrive 'sshd_config'
        @("HostKey $($key.Replace('\','/'))", 'Match User remotehelp,.\remotehelp Address !192.168.5.0/24,*', '    DenyUsers remotehelp .\remotehelp', '    PasswordAuthentication no', '    PubkeyAuthentication no', 'Match User remotehelp,.\remotehelp Address 192.168.5.0/24', '    PasswordAuthentication yes', '    PubkeyAuthentication no', '    PermitEmptyPasswords no') | Set-Content -LiteralPath $config -Encoding ASCII
        & $ssh -t -f $config
        $LASTEXITCODE | Should -Be 0
        $inside = & $ssh -T -f $config -C 'user=.\remotehelp,host=localhost,addr=192.168.5.3'
        $inside | Should -Contain 'passwordauthentication yes'
        foreach ($address in @('192.168.6.3','2001:db8::1')) {
            $outside = & $ssh -T -f $config -C "user=.\remotehelp,host=localhost,addr=$address"
            $outside | Should -Contain 'denyusers remotehelp'
            $outside | Should -Contain 'passwordauthentication no'
            $outside | Should -Contain 'pubkeyauthentication no'
        }
    }
}

Describe 'STOP_HIER cleanup' -Skip:($env:OS -ne 'Windows_NT') {
    BeforeAll {
        $script = Join-Path (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'windows') 'SSH_EINRICHTEN.ps1'
        $folder = Join-Path $env:ProgramData 'SysadminToolkit-RemoteHelp'
        $config = Join-Path $env:ProgramData 'ssh\sshd_config'
        $saved = "$config.pester-backup"
        $token = '0123456789abcdef0123456789abcdef'
        function New-FakeAccess {
            New-Item -ItemType Directory -Path $folder -Force | Out-Null
            # started=true: never restart the runner's real sshd with the test config
            [pscustomobject]@{ token = $token; name = 'remotehelp97'; sid = ''; started = $true } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $folder 'owner.json') -Encoding UTF8
        }
    }
    BeforeEach {
        if (Test-Path -LiteralPath $config) { Move-Item -LiteralPath $config -Destination $saved -Force }
    }
    AfterEach {
        if (Test-Path -LiteralPath $folder) { Remove-Item -LiteralPath $folder -Recurse -Force }
        if (Test-Path -LiteralPath $saved) { Move-Item -LiteralPath $saved -Destination $config -Force }
    }
    It 'finishes when sshd_config does not exist yet (Windows creates it on first service start)' {
        New-FakeAccess
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -Stop | Out-Host
        $LASTEXITCODE | Should -Be 0
        Test-Path -LiteralPath $folder | Should -BeFalse
    }
    It 'removes only its own block from an existing sshd_config' {
        New-FakeAccess
        New-Item -ItemType Directory -Path (Split-Path $config) -Force | Out-Null
        # sshd -t needs a host key; use a throwaway key so the runner's own keys do not matter.
        $key = Join-Path $TestDrive 'stop_host_key'
        $process = Start-Process "$env:WINDIR\System32\OpenSSH\ssh-keygen.exe" -ArgumentList "-q -t ed25519 -N `"`" -f `"$key`"" -NoNewWindow -PassThru
        $null = $process.Handle
        if (-not $process.WaitForExit(15000)) { $process.Kill(); throw 'ssh-keygen timeout' }
        $original = "Port 22`r`nHostKey $($key.Replace('\','/'))`r`nSubsystem sftp sftp-server.exe`r`n"
        $block = "# BEGIN SYSADMIN TOOLKIT REMOTEHELP $token`r`nMatch User remotehelp97`r`n    PasswordAuthentication no`r`n# END SYSADMIN TOOLKIT REMOTEHELP $token`r`n"
        [IO.File]::WriteAllText($config, $original + $block, [Text.Encoding]::ASCII)
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -Stop | Out-Host
        $LASTEXITCODE | Should -Be 0
        [IO.File]::ReadAllText($config) | Should -Be $original
        Remove-Item -LiteralPath $config -Force
    }
}

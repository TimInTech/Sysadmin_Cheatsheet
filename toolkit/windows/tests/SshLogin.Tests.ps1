Describe 'Windows OpenSSH password and session integration' {
    It 'accepts the password, rejects an incorrect one and ends an open session at the deadline' -Skip:($env:OS -ne 'Windows_NT') {
        if (-not (Test-Path $env:TOOLKIT_TEST_PYTHON)) { throw 'Isolierter Paramiko-Testclient fehlt.' }
        $toolkit = Split-Path $PSScriptRoot -Parent
        . (Join-Path $toolkit 'State.ps1')
        $exe = "$env:WINDIR\System32\OpenSSH\sshd.exe"
        if (-not (Test-Path $exe)) { throw 'OpenSSH Server fehlt.' }
        $suffix = [guid]::NewGuid().ToString('N').Substring(0, 9)
        $userName = "sshtest$suffix"
        $taskName = "SshTestSupervisor-$suffix"
        $password = [guid]::NewGuid().ToString('N') + 'aA1!'
        $secure = New-Object Security.SecureString
        foreach ($character in $password.ToCharArray()) { $secure.AppendChar($character) }
        $secure.MakeReadOnly()
        $user = $null; $workerStarted = $false; $client = $null
        try {
            $user = New-LocalUser -Name $userName -Password $secure -AccountExpires (Get-Date).AddMinutes(3)
            $key = Join-Path $TestDrive 'login_host_key'
            $keygen = Start-Process "$env:WINDIR\System32\OpenSSH\ssh-keygen.exe" -ArgumentList "-q -t ed25519 -N `"`" -f `"$key`"" -PassThru -NoNewWindow
            if (-not $keygen.WaitForExit(15000)) { $keygen.Kill(); throw 'ssh-keygen ueberschritt sein Zeitlimit.' }
            if ($keygen.ExitCode -ne 0) { throw 'Test-Hostschluessel konnte nicht erstellt werden.' }
            $probe = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
            $probe.Start(); $port = $probe.LocalEndpoint.Port; $probe.Stop()
            $config = Join-Path $TestDrive 'login_sshd_config'
            @("Port $port", 'ListenAddress 127.0.0.1', "HostKey `"$($key.Replace('\','/'))`"", "AllowUsers $userName@127.0.0.1", 'PasswordAuthentication yes', 'PubkeyAuthentication no', 'PermitEmptyPasswords no') | Set-Content -LiteralPath $config -Encoding ASCII
            $state = Join-Path $TestDrive 'login-supervisor.json'
            $ready = Join-Path $TestDrive 'login-supervisor-ready.json'
            Write-AtomicState -Path $state -State @{ Executable=$exe; Arguments="-D -f `"$config`""; DeadlineUtc=[DateTime]::UtcNow.AddSeconds(35).ToString('o'); ReadyPath=$ready }
            $supervisor = Join-Path $toolkit 'SshSupervisor.ps1'
            $hostExe = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
            $action = New-ScheduledTaskAction -Execute $hostExe -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$supervisor`" -StatePath `"$state`""
            Register-ScheduledTask -TaskName $taskName -Action $action -User 'SYSTEM' -RunLevel Highest | Out-Null
            Start-ScheduledTask -TaskName $taskName
            $workerStarted = $true
            $env:TOOLKIT_TEST_USER = $userName
            $env:TOOLKIT_TEST_PASSWORD = $password
            $env:TOOLKIT_TEST_PORT = [string]$port
            $out = Join-Path $TestDrive 'probe.out'
            $err = Join-Path $TestDrive 'probe.err'
            $script = Join-Path $PSScriptRoot 'ssh_login_probe.py'
            $client = Start-Process $env:TOOLKIT_TEST_PYTHON -ArgumentList @("`"$script`"") -RedirectStandardOutput $out -RedirectStandardError $err -PassThru
            if (-not $client.WaitForExit(65000)) { $client.Kill(); throw 'SSH-Anmeldetest ueberschritt sein Zeitlimit.' }
            if ($client.ExitCode -ne 0) { throw ('SSH-Anmeldetest fehlgeschlagen: ' + (Get-Content -LiteralPath $err -Raw)) }
            $output = Get-Content -LiteralPath $out -Raw
            $output | Should -Match 'AUTH_AND_SESSION_OK'
            $output | Should -Match 'SESSION_CLOSED'
        } finally {
            $secure.Dispose()
            Remove-Item Env:TOOLKIT_TEST_USER,Env:TOOLKIT_TEST_PASSWORD,Env:TOOLKIT_TEST_PORT -ErrorAction SilentlyContinue
            if ($client -and -not $client.HasExited) { $client.Kill() }
            if ($workerStarted) { Stop-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue }
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
            if ($user) {
                $current = Get-LocalUser -Name $userName -ErrorAction SilentlyContinue
                if ($current -and $current.SID.Value -eq $user.SID.Value) { Remove-LocalUser -SID $current.SID }
            }
        }
    }
}

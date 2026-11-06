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
        $user = $null; $client = $null; $action = $null; $port = $null
        $marker = "SysadminToolkitTest-$suffix"
        $oldUser = $env:TOOLKIT_TEST_USER; $oldPassword = $env:TOOLKIT_TEST_PASSWORD; $oldPort = $env:TOOLKIT_TEST_PORT
        try {
            $user = New-LocalUser -Name $userName -Password $secure -AccountExpires (Get-Date).AddMinutes(3) -Description $marker
            $key = Join-Path $TestDrive 'login_host_key'
            $keyError = Join-Path $TestDrive 'login-keygen.err'
            $keygen = Start-Process "$env:WINDIR\System32\OpenSSH\ssh-keygen.exe" -ArgumentList "-q -t ed25519 -N `"`" -f `"$key`"" -PassThru -NoNewWindow -RedirectStandardError $keyError
            $null = $keygen.Handle
            if (-not $keygen.WaitForExit(15000)) { $keygen.Kill(); throw 'ssh-keygen ueberschritt sein Zeitlimit.' }
            if ($keygen.ExitCode -ne 0) { throw "Test-Hostschluessel Fehler $($keygen.ExitCode): $(Get-Content $keyError -Raw)" }
            $probe = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
            $probe.Start(); $port = $probe.LocalEndpoint.Port; $probe.Stop()
            $config = Join-Path $TestDrive 'login_sshd_config'
            @("Port $port", 'ListenAddress 127.0.0.1', "HostKey `"$($key.Replace('\','/'))`"", "AllowUsers $userName@127.0.0.1", 'PasswordAuthentication yes', 'PubkeyAuthentication no', 'PermitEmptyPasswords no') | Set-Content -LiteralPath $config -Encoding ASCII
            & $exe -t -f $config
            if ($LASTEXITCODE -ne 0) { throw "Test-SSH-Konfiguration ungueltig: $LASTEXITCODE" }
            $state = Join-Path $TestDrive 'login-supervisor.json'
            $ready = Join-Path $TestDrive 'login-supervisor-ready.json'
            Write-AtomicState -Path $state -State @{ Executable=$exe; Arguments="-D -f `"$config`""; DeadlineUtc=[DateTime]::UtcNow.AddSeconds(35).ToString('o'); ReadyPath=$ready }
            $supervisor = Join-Path $toolkit 'SshSupervisor.ps1'
            $hostExe = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
            $action = New-ScheduledTaskAction -Execute $hostExe -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$supervisor`" -StatePath `"$state`""
            Register-ScheduledTask -TaskName $taskName -Action $action -User 'SYSTEM' -RunLevel Highest | Out-Null
            Start-ScheduledTask -TaskName $taskName
            $env:TOOLKIT_TEST_USER = $userName
            $env:TOOLKIT_TEST_PASSWORD = $password
            $env:TOOLKIT_TEST_PORT = [string]$port
            $out = Join-Path $TestDrive 'probe.out'
            $err = Join-Path $TestDrive 'probe.err'
            $script = Join-Path $PSScriptRoot 'ssh_login_probe.py'
            $client = Start-Process $env:TOOLKIT_TEST_PYTHON -ArgumentList @("`"$script`"") -RedirectStandardOutput $out -RedirectStandardError $err -PassThru
            $null = $client.Handle
            if (-not $client.WaitForExit(65000)) { $client.Kill(); throw 'SSH-Anmeldetest ueberschritt sein Zeitlimit.' }
            if ($client.ExitCode -ne 0) {
                $message = Get-Content -LiteralPath $err -Raw
                if ($message) { $message = $message.Replace($password, '[REDACTED]') }
                $taskInfo = Get-ScheduledTaskInfo -TaskName $taskName -ErrorAction SilentlyContinue
                $taskState = (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue).State
                $readyExists = Test-Path -LiteralPath $ready
                $listenerExists = [bool](Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue)
                throw ("SSH-Test fehlgeschlagen; Task=$taskState Result=$($taskInfo.LastTaskResult) Ready=$readyExists Listener=$listenerExists; " + $message)
            }
            $output = Get-Content -LiteralPath $out -Raw
            $output | Should -Match 'AUTH_AND_SESSION_OK'
            $output | Should -Match 'SESSION_CLOSED'
        } finally {
            $cleanupErrors = New-Object 'System.Collections.Generic.List[string]'
            $secure.Dispose()
            $env:TOOLKIT_TEST_USER = $oldUser; $env:TOOLKIT_TEST_PASSWORD = $oldPassword; $env:TOOLKIT_TEST_PORT = $oldPort
            try {
                if ($client -and -not $client.HasExited) {
                    $client.Kill()
                    if (-not $client.WaitForExit(10000)) { throw 'Testclient laeuft weiterhin.' }
                }
            } catch { $cleanupErrors.Add('Testclient konnte nicht beendet werden.') }
            try {
                $current = Get-LocalUser -Name $userName -ErrorAction SilentlyContinue
                if ($current) {
                    if (($user -and $current.SID.Value -ne $user.SID.Value) -or (-not $user -and $current.Description -cne $marker)) { throw 'Kontoidentitaet stimmt nicht ueberein.' }
                    Disable-LocalUser -SID $current.SID -ErrorAction Stop
                }
            } catch { $cleanupErrors.Add('Testkonto konnte nicht sicher deaktiviert werden.') }
            try {
                $task = Get-ScheduledTask -TaskName $taskName -TaskPath '\' -ErrorAction SilentlyContinue
                if ($task) {
                    if (-not $action -or @($task.Actions).Count -ne 1 -or $task.Actions[0].Execute -ine $action.Execute -or $task.Actions[0].Arguments -cne $action.Arguments) { throw 'Aufgabenidentitaet stimmt nicht ueberein.' }
                    if ($task.State -eq 'Running') { Stop-ScheduledTask -InputObject $task -ErrorAction Stop }
                    . (Join-Path $toolkit 'TaskStop.ps1')
                    Wait-SupervisorTaskStopped -Name $taskName
                    Unregister-ScheduledTask -InputObject $task -Confirm:$false -ErrorAction Stop
                    if (Get-ScheduledTask -TaskName $taskName -TaskPath '\' -ErrorAction SilentlyContinue) { throw 'Aufgabe existiert weiterhin.' }
                }
            } catch { $cleanupErrors.Add('Testaufgabe konnte nicht sicher beendet und entfernt werden.') }
            try {
                $current = Get-LocalUser -Name $userName -ErrorAction SilentlyContinue
                if ($current) {
                    if (($user -and $current.SID.Value -ne $user.SID.Value) -or (-not $user -and $current.Description -cne $marker)) { throw 'Kontoidentitaet stimmt nicht ueberein.' }
                    Remove-LocalUser -SID $current.SID -ErrorAction Stop
                    if (Get-LocalUser -Name $userName -ErrorAction SilentlyContinue) { throw 'Konto existiert weiterhin.' }
                }
            } catch { $cleanupErrors.Add('Testkonto konnte nicht sicher entfernt werden.') }
            try {
                if ($port -and (Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue | Where-Object LocalAddress -eq '127.0.0.1')) { throw 'Testlistener existiert weiterhin.' }
            } catch { $cleanupErrors.Add('Testlistener wurde nicht vollstaendig beendet.') }
            $password = $null
            if ($cleanupErrors.Count -gt 0) { throw ($cleanupErrors -join ' ') }
        }
    }
}

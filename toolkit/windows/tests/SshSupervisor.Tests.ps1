Describe 'Supervised process lifecycle' {
    BeforeAll {
        $windows = $env:OS -eq 'Windows_NT'
        $toolkit = Split-Path $PSScriptRoot -Parent
        . (Join-Path $toolkit 'State.ps1')
    }
    It 'keeps a process until its deadline and then closes its job' -Skip:($env:OS -ne 'Windows_NT') {
        $statePath = Join-Path $TestDrive 'supervisor.json'
        $readyPath = Join-Path $TestDrive 'ready.json'
        $state = @{ Executable="$env:WINDIR\System32\cmd.exe"; Arguments='/c ping -n 120 127.0.0.1 > nul'; DeadlineUtc=[DateTime]::UtcNow.AddSeconds(12).ToString('o'); ReadyPath=$readyPath }
        Write-AtomicState -Path $statePath -State $state
        $script = Join-Path $toolkit 'SshSupervisor.ps1'
        $hostExe = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
        $worker = Start-Process $hostExe -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$script`"",'-StatePath',"`"$statePath`"") -PassThru
        try {
            $deadline = (Get-Date).AddSeconds(10)
            while (-not (Test-Path $readyPath) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 100 }
            Test-Path $readyPath | Should -BeTrue
            $childPid = [int](Get-Content $readyPath -Raw | ConvertFrom-Json).ProcessId
            Get-Process -Id $childPid -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            $worker | Wait-Process -Timeout 25
            Get-Process -Id $childPid -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        } finally {
            Stop-Process -Id $worker.Id -Force -ErrorAction SilentlyContinue
            if ($childPid) { Get-Process -Id $childPid -ErrorAction SilentlyContinue | Where-Object ProcessName -eq 'cmd' | Stop-Process -Force -ErrorAction SilentlyContinue }
        }
    }
    It 'does not start a process for an expired state' -Skip:($env:OS -ne 'Windows_NT') {
        $statePath = Join-Path $TestDrive 'expired-supervisor.json'
        $readyPath = Join-Path $TestDrive 'expired-ready.json'
        Write-AtomicState -Path $statePath -State @{ Executable="$env:WINDIR\System32\cmd.exe"; Arguments='/c exit 0'; DeadlineUtc=[DateTime]::UtcNow.AddSeconds(-1).ToString('o'); ReadyPath=$readyPath }
        & (Join-Path $toolkit 'SshSupervisor.ps1') -StatePath $statePath
        Test-Path $readyPath | Should -BeFalse
    }
    It 'starts a real OpenSSH listener and removes it at the deadline' -Skip:($env:OS -ne 'Windows_NT') {
        $exe = "$env:WINDIR\System32\OpenSSH\sshd.exe"
        if (-not (Test-Path $exe)) { throw 'OpenSSH Server fehlt auf dem Testsystem.' }
        $key = Join-Path $TestDrive 'host_ed25519'
        $keyError = Join-Path $TestDrive 'listener-keygen.err'
        $keygen = Start-Process "$env:WINDIR\System32\OpenSSH\ssh-keygen.exe" -ArgumentList "-q -t ed25519 -N `"`" -f `"$key`"" -PassThru -NoNewWindow -RedirectStandardError $keyError
        if (-not $keygen.WaitForExit(15000)) { $keygen.Kill(); throw 'ssh-keygen ueberschritt sein Zeitlimit.' }
        if ($keygen.ExitCode -ne 0) { throw "Test-Hostschluessel Fehler $($keygen.ExitCode): $(Get-Content $keyError -Raw)" }
        $probe = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
        $probe.Start(); $port = $probe.LocalEndpoint.Port; $probe.Stop()
        $config = Join-Path $TestDrive 'test_sshd_config'
        @("Port $port", 'ListenAddress 127.0.0.1', "HostKey $($key.Replace('\','/'))", 'DenyUsers *', 'PasswordAuthentication yes', 'PubkeyAuthentication no', 'PermitEmptyPasswords no') | Set-Content -LiteralPath $config -Encoding ASCII
        $statePath = Join-Path $TestDrive 'real-sshd-state.json'
        $readyPath = Join-Path $TestDrive 'real-sshd-ready.json'
        Write-AtomicState -Path $statePath -State @{ Executable=$exe; Arguments="-D -f `"$config`""; DeadlineUtc=[DateTime]::UtcNow.AddSeconds(20).ToString('o'); ReadyPath=$readyPath }
        $script = Join-Path $toolkit 'SshSupervisor.ps1'
        $hostExe = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
        $worker = Start-Process $hostExe -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$script`"",'-StatePath',"`"$statePath`"") -PassThru
        try {
            $banner = $null; $limit = (Get-Date).AddSeconds(15)
            while (-not $banner -and (Get-Date) -lt $limit) {
                $client = New-Object Net.Sockets.TcpClient
                try {
                    $client.ReceiveTimeout = 1000
                    $client.Connect('127.0.0.1', $port)
                    $reader = New-Object IO.StreamReader($client.GetStream())
                    $banner = $reader.ReadLine()
                } catch { Start-Sleep -Milliseconds 200 } finally { $client.Dispose() }
            }
            $banner | Should -Match '^SSH-2\.0-'
            $worker | Wait-Process -Timeout 25
            $listener = Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue
            $listener | Should -BeNullOrEmpty
        } finally { Stop-Process -Id $worker.Id -Force -ErrorAction SilentlyContinue }
    }
}

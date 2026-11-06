Describe 'Windows job supervisor' {
    BeforeAll {
        $source = Join-Path (Split-Path $PSScriptRoot -Parent) 'JobSupervisor.cs'
        Add-Type -Path $source
        $onWindows = $env:OS -eq 'Windows_NT'
    }
    It 'compiles the native supervisor type' {
        ('RemoteHelp.JobSupervisor' -as [type]) | Should -Not -BeNullOrEmpty
    }
    It 'ends a child when its supervisor is killed' -Skip:($env:OS -ne 'Windows_NT') {
        $pidFile = Join-Path $TestDrive 'child.pid'
        $escapedSource = $source.Replace("'", "''")
        $escapedPid = $pidFile.Replace("'", "''")
        $code = @"
Add-Type -Path '$escapedSource'
`$job = [RemoteHelp.JobSupervisor]::Start(`"`$env:WINDIR\System32\cmd.exe`", '/c ping -n 120 127.0.0.1 > nul')
[IO.File]::WriteAllText('$escapedPid', [string]`$job.ProcessId)
Start-Sleep -Seconds 120
"@
        $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($code))
        $controller = Start-Process -FilePath "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList @('-NoProfile','-EncodedCommand',$encoded) -PassThru
        try {
            $deadline = (Get-Date).AddSeconds(20)
            while (-not (Test-Path $pidFile) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 100 }
            Test-Path $pidFile | Should -BeTrue
            $childPid = [int](Get-Content -LiteralPath $pidFile -Raw)
            Get-Process -Id $childPid -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            $deadline = (Get-Date).AddSeconds(10)
            do {
                $grandchild = Get-CimInstance Win32_Process -Filter "ParentProcessId=$childPid" | Where-Object Name -eq 'PING.EXE' | Select-Object -First 1
                if (-not $grandchild) { Start-Sleep -Milliseconds 100 }
            } while (-not $grandchild -and (Get-Date) -lt $deadline)
            $grandchild | Should -Not -BeNullOrEmpty
            $grandchildPid = [int]$grandchild.ProcessId
            Stop-Process -Id $controller.Id -Force
            $deadline = (Get-Date).AddSeconds(10)
            while (((Get-Process -Id $childPid -ErrorAction SilentlyContinue) -or (Get-Process -Id $grandchildPid -ErrorAction SilentlyContinue)) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 100 }
            Get-Process -Id $childPid -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
            Get-Process -Id $grandchildPid -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        } finally {
            Stop-Process -Id $controller.Id -Force -ErrorAction SilentlyContinue
            if ($childPid) { Get-Process -Id $childPid -ErrorAction SilentlyContinue | Where-Object ProcessName -eq 'cmd' | Stop-Process -Force -ErrorAction SilentlyContinue }
            if ($grandchildPid) { Get-Process -Id $grandchildPid -ErrorAction SilentlyContinue | Where-Object ProcessName -eq 'PING' | Stop-Process -Force -ErrorAction SilentlyContinue }
        }
    }
}

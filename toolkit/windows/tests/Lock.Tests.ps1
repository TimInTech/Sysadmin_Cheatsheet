BeforeAll { . (Join-Path (Split-Path $PSScriptRoot -Parent) 'State.ps1') }
Describe 'RemoteHelp state lock' {
    It 'releases the mutex after an exception' {
        $name = 'toolkit-test-' + [guid]::NewGuid().ToString('N')
        { Invoke-WithRemoteHelpLock -Name $name -Action { throw 'intentional' } } | Should -Throw
        Invoke-WithRemoteHelpLock -Name $name -Action { 'acquired' } | Should -Be 'acquired'
    }
    It 'prevents another process from entering while the lock is held' {
        $name = 'toolkit-test-' + [guid]::NewGuid().ToString('N')
        $stateScript = Join-Path (Split-Path $PSScriptRoot -Parent) 'State.ps1'
        Invoke-WithRemoteHelpLock -Name $name -Action {
            $job = Start-Job -ScriptBlock {
                param($path, $mutexName)
                . $path
                try { Invoke-WithRemoteHelpLock -Name $mutexName -TimeoutMilliseconds 100 -Action { 'unexpected' } } catch { 'blocked' }
            } -ArgumentList $stateScript,$name
            try { $job | Wait-Job -Timeout 15 | Out-Null; Receive-Job $job | Should -Be 'blocked' }
            finally { $job | Remove-Job -Force }
        }
    }
}

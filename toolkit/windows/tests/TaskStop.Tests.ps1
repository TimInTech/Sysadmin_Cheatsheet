BeforeAll {
    function Get-ScheduledTask { param($TaskName, $TaskPath) }
    . (Join-Path (Split-Path $PSScriptRoot -Parent) 'TaskStop.ps1')
}
Describe 'Wait for task termination' {
    It 'fails closed when a task remains running' {
        Mock Get-ScheduledTask { [pscustomobject]@{ State='Running' } }
        { Wait-SupervisorTaskStopped -Name 'test' -TimeoutMilliseconds 10 } | Should -Throw '*laeuft weiterhin*'
    }
    It 'accepts a task that is no longer running' {
        Mock Get-ScheduledTask { [pscustomobject]@{ State='Ready' } }
        { Wait-SupervisorTaskStopped -Name 'test' -TimeoutMilliseconds 10 } | Should -Not -Throw
    }
}

function Wait-SupervisorTaskStopped {
    param([Parameter(Mandatory=$true)][string]$Name, [int]$TimeoutMilliseconds = 10000)
    $deadline = [DateTime]::UtcNow.AddMilliseconds($TimeoutMilliseconds)
    do {
        $task = Get-ScheduledTask -TaskName $Name -TaskPath '\' -ErrorAction Stop
        if ($task.State -ne 'Running') { return }
        Start-Sleep -Milliseconds 100
    } while ([DateTime]::UtcNow -lt $deadline)
    throw 'Die Supervisor-Aufgabe laeuft weiterhin. Der Rueckbau wurde angehalten.'
}

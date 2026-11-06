param([Parameter(Mandatory=$true)][string]$StatePath)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\State.ps1"
$state = Get-Content -LiteralPath $StatePath -Raw | ConvertFrom-Json
$deadline = [DateTime]::Parse($state.DeadlineUtc, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind).ToUniversalTime()
if ([DateTime]::UtcNow -ge $deadline) { return }
Add-Type -Path "$PSScriptRoot\JobSupervisor.cs"
$job = $null
try {
    $job = [RemoteHelp.JobSupervisor]::Start($state.Executable, $state.Arguments)
    Write-AtomicState -Path $state.ReadyPath -State @{ ProcessId=$job.ProcessId }
    $process = Get-Process -Id $job.ProcessId -ErrorAction Stop
    while ([DateTime]::UtcNow -lt $deadline -and -not $process.HasExited) {
        $remaining = ($deadline - [DateTime]::UtcNow).TotalMilliseconds
        if ($remaining -gt 0) { Start-Sleep -Milliseconds ([int][Math]::Min(500, [Math]::Ceiling($remaining))) }
        $process.Refresh()
    }
} finally {
    if ($job) { $job.Dispose() }
}

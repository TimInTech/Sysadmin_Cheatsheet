function Write-AtomicState {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)]$State,
        [ValidateRange(1,100)][int]$Depth = 10
    )
    $json = ConvertTo-Json -InputObject $State -Depth $Depth -ErrorAction Stop
    $bytes = (New-Object System.Text.UTF8Encoding($false)).GetBytes($json)
    $temporary = "$Path.$([guid]::NewGuid().ToString('N')).tmp"
    $backup = "$temporary.bak"
    try {
        $stream = New-Object System.IO.FileStream($temporary, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
        try { $stream.Write($bytes, 0, $bytes.Length); $stream.Flush($true) } finally { $stream.Dispose() }
        if ([System.IO.File]::Exists($Path)) {
            [System.IO.File]::Replace($temporary, $Path, $backup)
        } else {
            [System.IO.File]::Move($temporary, $Path)
        }
    } finally {
        if ([System.IO.File]::Exists($temporary)) { [System.IO.File]::Delete($temporary) }
        if ([System.IO.File]::Exists($backup)) { [System.IO.File]::Delete($backup) }
    }
}

function Invoke-WithRemoteHelpLock {
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][scriptblock]$Action,
        [int]$TimeoutMilliseconds = -1
    )
    $mutex = New-Object System.Threading.Mutex($false, $Name)
    $acquired = $false
    try {
        try { $acquired = $mutex.WaitOne($TimeoutMilliseconds) }
        catch [System.Threading.AbandonedMutexException] { $acquired = $true }
        if (-not $acquired) { throw 'Eine andere Toolkit-Aktion laeuft bereits.' }
        & $Action
    } finally {
        if ($acquired) { $mutex.ReleaseMutex() }
        $mutex.Dispose()
    }
}

# The caller must hold the same cross-process lock for the full transaction.
function Set-ResourceIntent {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][ValidateSet('account','firewall','service','task','process')][string]$Kind,
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Identity,
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Marker
    )
    if ([IO.File]::Exists($Path)) { throw 'Eine bisher nicht aufgeloeste Ressourcenabsicht existiert bereits.' }
    Write-AtomicState -Path $Path -State ([ordered]@{ Kind=$Kind; Identity=$Identity; Marker=$Marker; Phase='pending' })
}

function Set-ResourceApplied {
    param([Parameter(Mandatory=$true)][string]$Path, [Parameter(Mandatory=$true)][string]$Identity)
    $record = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    if ($record.Identity -cne $Identity -or $record.Phase -cne 'pending') { throw 'Die Ressourcenabsicht passt nicht zur Aktion.' }
    $record.Phase = 'applied'
    Write-AtomicState -Path $Path -State $record
}

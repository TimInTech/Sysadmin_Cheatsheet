# Shared helpers for the Windows toolkit. Windows PowerShell 5.1, ASCII only
# (PS 5.1 reads BOM-less scripts as ANSI, so umlauts are written as ae/oe/ue).

function Test-ToolkitAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    return ([Security.Principal.WindowsPrincipal]$identity).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Returns $true when the current process is elevated. Otherwise starts an
# elevated copy of the script (with -Pause, so its window stays open) and
# returns $false; the caller must then stop.
function Request-ToolkitAdmin {
    param(
        [Parameter(Mandatory = $true)][string]$ScriptPath,
        [string[]]$Arguments = @()
    )
    if (Test-ToolkitAdmin) { return $true }
    Write-Host 'Dafuer sind Administratorrechte noetig.'
    Write-Host 'Windows fragt gleich: "Moechten Sie zulassen, dass durch diese App Aenderungen ..." -> bitte "Ja" waehlen.'
    $argumentList = @('-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"{0}"' -f $ScriptPath)) + $Arguments + @('-Pause')
    try {
        Start-Process -FilePath "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" -Verb RunAs -ArgumentList $argumentList -ErrorAction Stop | Out-Null
        Write-Host ''
        Write-Host 'Ein NEUES Fenster mit Administratorrechten wurde geoeffnet. Dort geht es weiter.' -ForegroundColor Green
        Write-Host 'Dieses Fenster hier kann geschlossen werden.'
    } catch {
        Write-ToolkitError -Was 'Die Administratorrechte wurden nicht erteilt. Es wurde nichts geaendert.' -Tun 'Die Datei erneut starten und bei der Windows-Abfrage "Ja" waehlen.'
    }
    return $false
}

function Write-ToolkitStep([string]$Text) { Write-Host ''; Write-Host ">> $Text" -ForegroundColor Cyan }
function Write-ToolkitOk([string]$Text) { Write-Host "   [OK] $Text" -ForegroundColor Green }
function Write-ToolkitProblem([string]$Text) { Write-Host "   [PROBLEM] $Text" -ForegroundColor Yellow }
function Write-ToolkitInfo([string]$Text) { Write-Host "   $Text" }

function Write-ToolkitError {
    param([string]$Was, [string]$Tun)
    Write-Host ''
    Write-Host "FEHLER: $Was" -ForegroundColor Red
    if ($Tun) { Write-Host "Was du tun kannst: $Tun" }
}

function Wait-ToolkitExit {
    Write-Host ''
    [void](Read-Host 'Enter druecken, um dieses Fenster zu schliessen')
}

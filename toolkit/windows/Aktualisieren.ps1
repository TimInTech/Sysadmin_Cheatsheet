# Windows after a fresh install: install all Windows updates incl. drivers (Microsoft Update).
# Needs: Windows PowerShell 5.1 as administrator, internet. Does not touch SSH.
param([switch]$Pause)
$ErrorActionPreference = 'Stop'
$common = Join-Path $PSScriptRoot 'Gemeinsam.ps1'
if (-not (Test-Path -LiteralPath $common)) {
    Write-Host 'FEHLER: Gemeinsam.ps1 fehlt. Bitte den ganzen Ordner "windows" entpacken, nicht nur einzelne Dateien.' -ForegroundColor Red
    exit 1
}
. $common

if ($PSVersionTable.PSEdition -ne 'Desktop') {
    Write-ToolkitError -Was 'Dieses Programm braucht Windows PowerShell 5.1, nicht PowerShell 7.' -Tun 'WINDOWS_AKTUALISIEREN.cmd per Doppelklick starten.'
    exit 1
}
if (-not (Request-ToolkitAdmin -ScriptPath $PSCommandPath)) { exit 0 }

$exitCode = 0
try {
    Write-Host 'Dieses Programm sucht und installiert alle Windows-Updates und Treiber.'
    Write-Host 'Es startet den Rechner NICHT von selbst neu. Das kann einige Minuten bis Stunden dauern.'
    if ((Read-Host 'Fortfahren? (j/n)') -ne 'j') { Write-Host 'Abgebrochen. Es wurde nichts geaendert.'; return }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-ToolkitStep 'Update-Modul vorbereiten (PSWindowsUpdate aus dem PowerShell-Katalog)'
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) { Install-Module PSWindowsUpdate -Force }
    Import-Module PSWindowsUpdate
    Write-ToolkitOk 'Update-Modul bereit'

    # Updates can reveal further updates, so run up to four rounds without rebooting.
    foreach ($round in 1..4) {
        Write-ToolkitStep "Durchlauf $round von maximal 4: Updates suchen und installieren"
        $found = Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot
        if (-not $found) { Write-ToolkitOk 'Keine weiteren Updates gefunden'; break }
    }

    if (Get-WURebootStatus -Silent) {
        Write-Host ''
        Write-Host 'Ein Neustart ist noetig. Danach WINDOWS_AKTUALISIEREN.cmd noch einmal starten,' -ForegroundColor Yellow
        Write-Host 'bis kein Neustart und keine neuen Updates mehr gemeldet werden.' -ForegroundColor Yellow
        if ((Read-Host 'Jetzt neu starten? (j/n)') -eq 'j') { Restart-Computer }
    } else {
        Write-Host ''
        Write-Host 'Fertig. Windows ist auf dem aktuellen Stand.' -ForegroundColor Green
    }
} catch {
    $exitCode = 1
    Write-ToolkitError -Was $_.Exception.Message -Tun 'Internetverbindung pruefen und erneut starten. Hilft das nicht, die Meldung der helfenden Person schicken.'
} finally {
    if ($Pause) { Wait-ToolkitExit }
}
exit $exitCode

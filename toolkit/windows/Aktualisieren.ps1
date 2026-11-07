# Windows after a fresh install: install all Windows updates incl. drivers (Microsoft Update).
# Needs: Windows PowerShell 5.1 as administrator, internet. Does not touch SSH.
$ErrorActionPreference = 'Stop'

$identity = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $identity.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Bitte WINDOWS_AKTUALISIEREN.cmd mit Rechtsklick -> "Als Administrator ausfuehren" starten.'
    return
}
if ($PSVersionTable.PSEdition -ne 'Desktop') {
    Write-Host 'Bitte Windows PowerShell 5.1 verwenden (nicht PowerShell 7).'
    return
}

Write-Host 'Dieses Programm sucht und installiert alle Windows-Updates und Treiber.'
Write-Host 'Es startet den Rechner NICHT von selbst neu. Das kann einige Minuten bis Stunden dauern.'
if ((Read-Host 'Fortfahren? (j/n)') -ne 'j') { return }

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host 'Bereite das Update-Modul vor (PSWindowsUpdate aus dem PowerShell-Katalog)...'
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) { Install-Module PSWindowsUpdate -Force }
Import-Module PSWindowsUpdate

# Updates can reveal further updates, so run up to four rounds without rebooting.
foreach ($round in 1..4) {
    Write-Host "Durchlauf $round von maximal 4..."
    $found = Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot
    if (-not $found) { break }
}

if (Get-WURebootStatus -Silent) {
    Write-Host ''
    Write-Host 'Ein Neustart ist noetig. Danach WINDOWS_AKTUALISIEREN.cmd noch einmal starten,'
    Write-Host 'bis kein Neustart und keine neuen Updates mehr gemeldet werden.'
    if ((Read-Host 'Jetzt neu starten? (j/n)') -eq 'j') { Restart-Computer }
} else {
    Write-Host 'Fertig. Windows ist auf dem aktuellen Stand.'
}

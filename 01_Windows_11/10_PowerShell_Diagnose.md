# 10 PowerShell-Diagnose (Windows 11)

PowerShell-Befehle für Systemdiagnose, Ereignisprotokolle, Dienste, Netzwerk und Sicherheit.

## 1. Systeminformationen

```powershell
# Ausführliche Systeminformationen
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer, CsName, CsManufacturer, CsModel

# Klassische Systeminfo
systeminfo

# Windows-Version im Dialog
winver

# Laufwerke, Datenträger und Partitionen
Get-Volume
Get-Disk
Get-Partition
```

## 2. Ereignisprotokolle (Event Logs)

```powershell
# Kritische Systemfehler der letzten 7 Tage
Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2; StartTime=(Get-Date).AddDays(-7)} |
  Select-Object TimeCreated, Id, ProviderName, Message -First 50

# Kritische Anwendungsfehler der letzten 7 Tage
Get-WinEvent -FilterHashtable @{LogName='Application'; Level=1,2; StartTime=(Get-Date).AddDays(-7)} |
  Select-Object TimeCreated, Id, ProviderName, Message -First 50
```

## 3. Dienste und Task Scheduler

```powershell
# Alle Dienste sortiert nach Status
Get-Service | Sort-Object Status, Name

# Gestoppte Dienste anzeigen
Get-Service | Where-Object Status -eq 'Stopped'

# Nicht deaktivierte geplante Tasks anzeigen
Get-ScheduledTask | Where-Object State -ne 'Disabled' | Select-Object TaskName, TaskPath, State
```

## 4. Netzwerkdiagnose

```powershell
# IP-Konfiguration und DNS
Get-NetIPConfiguration
Get-DnsClientServerAddress
Resolve-DnsName example.com

# Verbindungstest
Test-NetConnection -ComputerName example.com -Port 443

# Firewall-Profile
Get-NetFirewallProfile
```

## 5. BitLocker und Defender

```powershell
# BitLocker-Status
Get-BitLockerVolume
manage-bde -status

# Microsoft Defender Status
Get-MpComputerStatus
Get-MpPreference
```

## 6. DISM und SFC

```powershell
# System-Image reparieren
DISM /Online /Cleanup-Image /RestoreHealth

# Systemdateien prüfen
sfc /scannow
```

# 01 Update und Upgrade (Windows 11)

Befehle für die Aktualisierung des Betriebssystems über die Kommandozeile (PowerShell).

## 1. PSWindowsUpdate Modul

Das Modul `PSWindowsUpdate` bietet eine mächtige Schnittstelle, um Windows-Updates ohne GUI zu steuern.

```powershell
# 1. Modul installieren (als Administrator)
Install-Module PSWindowsUpdate -Force

# 2. Modul importieren
Import-Module PSWindowsUpdate

# 3. Alle verfügbaren Updates suchen
Get-WindowsUpdate

# 4. Alle Updates (inkl. Treiber) herunterladen und automatisch installieren
Install-WindowsUpdate -AcceptAll -AutoReboot

# 5. Spezifisches Update anhand der KB-Nummer installieren
Install-WindowsUpdate -KBArticleID KB5001234 -AcceptAll
```

## 2. Feature- und Store-Updates erzwingen

Manchmal hängen App-Updates aus dem Microsoft Store oder Feature-Updates. So lassen sich diese anstoßen:

### 2.1 Microsoft Store Apps aktualisieren
```powershell
# Startet den Microsoft Store Update-Prozess für alle vorinstallierten und bezogenen Apps
Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod
```

### 2.2 Feature-Update / Upgrade steuern
Windows-Upgrades lassen sich per Windows Update Assistent oder per ISO steuern:
```cmd
:: ISO mounten und Upgrade ohne Nutzerinteraktion starten (Unattended)
setup.exe /auto upgrade /quiet /migratedrivers all /showoobe none /postoobe "C:\skript.bat"
```

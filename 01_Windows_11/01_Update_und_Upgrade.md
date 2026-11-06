# 01 Update und Upgrade (Windows 10 und 11)

Befehle für die Aktualisierung des Betriebssystems über die Kommandozeile (PowerShell).

> [!IMPORTANT]
> **Nach jeder Neuinstallation zuerst: Windows komplett aktualisieren.** Erst danach Software, Treiber und Einstellungen. Abschnitt 1 holt alle Updates und Treiber in einem Durchlauf.

## 1. Nach der Neuinstallation: alles in einem Durchlauf

Voraussetzungen:

- Internetverbindung.
- **Windows PowerShell** (blaues Symbol, `powershell.exe`) **als Administrator**: Startmenü → „PowerShell“ → Rechtsklick → *Als Administrator ausführen*. Die neue PowerShell 7 (`pwsh`) dafür nicht verwenden; das Modul ist für Windows PowerShell 5.1 gedacht.
- Die Erlaubnis, Skripte auszuführen (siehe Abschnitt 2). Der erste Befehl unten erledigt das nur für dieses eine Fenster.

```powershell
# 1. Skripte nur für dieses Fenster erlauben (nach dem Schließen wieder aus)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# 2. Verschlüsselung für den PowerShell-Katalog sicherstellen (nötig bei älterem Windows 10)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 3. Paketquelle und Modul einrichten (ohne Rückfragen)
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate

# 4. Alle Updates inklusive Treiber und Microsoft-Produkten installieren, ohne Neustart
#    (bis zu vier Durchläufe, weil nach Updates oft neue erscheinen)
foreach ($durchlauf in 1..4) {
    $gefunden = Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot
    if (-not $gefunden) { break }
}

# 5. Prüfen, ob ein Neustart nötig ist, und einmal neu starten
if (Get-WURebootStatus -Silent) { Restart-Computer }
```

Nach dem Neustart den Block ab **Schritt 1** noch einmal ausführen (Schritt 3 darf dabei übersprungen werden). Windows bietet manche Updates erst nach einem Neustart an. Damit sind in der Regel **ein bis zwei Neustarts** nötig statt vieler. Erscheint beim zweiten Durchgang nichts mehr, ist das System aktuell.

> [!NOTE]
> `-IgnoreReboot` verschiebt den Neustart nur, es verhindert ihn nicht. Updates, die einen Neustart brauchen, werden erst danach fertig eingerichtet. Wer das System während der Installation nicht anfassen will, nimmt stattdessen `-AutoReboot`. Dann startet der Rechner selbstständig neu und der Block muss danach von Hand wiederholt werden.

### 1.1 Treiber gezielt prüfen

```powershell
# Welche Treiber-Updates bietet Windows Update an?
Get-WindowsUpdate -MicrosoftUpdate -UpdateType Driver

# Treiber-Updates installieren
Get-WindowsUpdate -MicrosoftUpdate -UpdateType Driver -AcceptAll -Install -IgnoreReboot

# Geräte mit fehlendem oder fehlerhaftem Treiber anzeigen
Get-PnpDevice -PresentOnly | Where-Object Status -eq 'Error' | Format-Table FriendlyName, InstanceId, Problem -AutoSize
```

Taucht danach noch ein Gerät mit Status `Error` auf, den Treiber beim Hersteller des Geräts oder Mainboards herunterladen, entpacken und installieren:

```powershell
# Alle Treiber (.inf) in einem Ordner samt Unterordnern installieren
pnputil /add-driver "D:\Treiber\*.inf" /subdirs /install
```

Grafikkarten- und Chipsatztreiber stammen am zuverlässigsten direkt von Intel, AMD oder NVIDIA. Für Intel-Systeme bietet [Intel Driver & Support Assistant](https://www.intel.com/content/www/us/en/support/detect.html) eine automatische Erkennung.

### 1.2 Programme und Store-Apps aktualisieren

```powershell
# Installierte Programme und Store-Apps über winget aktualisieren
winget upgrade --all --accept-source-agreements --accept-package-agreements --silent
```

Fehlt `winget`, steht die Nachinstallation in [02 Standardsoftware Deployment](02_Standardsoftware_Deployment.md).

### 1.3 Weitere Modul-Befehle

```powershell
# Alle verfügbaren Updates nur anzeigen
Get-WindowsUpdate -MicrosoftUpdate

# Spezifisches Update anhand der KB-Nummer installieren
Get-WindowsUpdate -KBArticleID KB5001234 -AcceptAll -Install

# Letzte Update-Ergebnisse und Installationshistorie
Get-WULastResults
Get-WUHistory | Format-Table -AutoSize
```

`Install-WindowsUpdate` ist ein Alias für `Get-WindowsUpdate -Install`. Beide Schreibweisen sind gleichwertig.

### 1.4 Updates automatisieren

Gilt für Windows PowerShell 5.1 (`Register-ScheduledJob` gibt es in PowerShell 7 nicht).

```powershell
# Wöchentlichen Update-Auftrag anlegen (sonntags um 03:00 Uhr)
$trigger = New-JobTrigger -Weekly -DaysOfWeek Sunday -At '3:00AM'
Register-ScheduledJob -Name 'AutoUpdate' -Trigger $trigger -ScriptBlock {
    Import-Module PSWindowsUpdate
    Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -AutoReboot
}

# Auftrag wieder entfernen
Unregister-ScheduledJob -Name 'AutoUpdate'
```

## 2. Skripte ausführen dürfen (Execution Policy)

Windows blockiert PowerShell-Skripte standardmäßig. Die Meldung lautet „Die Ausführung von Skripts ist auf diesem System deaktiviert“ oder „… nicht digital signiert“. Das betrifft nur Skriptdateien (`.ps1`), nicht einzelne Befehle, die man ins Fenster tippt.

```powershell
# Aktuelle Einstellung je Bereich anzeigen
Get-ExecutionPolicy -List
```

| Bereich | Wirkung | Empfehlung |
| --- | --- | --- |
| `Process` | Nur das aktuelle Fenster, danach weg | **Standardweg für Einmal-Aufgaben** |
| `CurrentUser` | Dauerhaft für den eigenen Benutzer | Für Entwickler und Administratoren |
| `LocalMachine` | Dauerhaft für alle Benutzer, braucht Administratorrechte | Nur bewusst setzen |
| `MachinePolicy` / `UserPolicy` | Von der Gruppenrichtlinie vorgegeben | Lässt sich lokal nicht ändern |

```powershell
# Nur für dieses Fenster (empfohlen)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Dauerhaft für den eigenen Benutzer: lokale Skripte erlaubt, heruntergeladene brauchen Signatur
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# Einzelnes Skript ohne Änderung der Einstellung starten
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\skript.ps1

# Heruntergeladene Datei freigeben (entfernt die Markierung "aus dem Internet")
Unblock-File .\skript.ps1
```

> [!WARNING]
> Die Execution Policy ist ein Schutz vor versehentlichem Ausführen, **keine Sicherheitsgrenze**. Skripte aus dem Internet vor dem Start lesen. Ist `MachinePolicy` oder `UserPolicy` gesetzt, überstimmt die Gruppenrichtlinie jede lokale Einstellung. Dann Administrator der Domäne fragen.

## 3. Unterschiede zwischen den Windows-Versionen

| Punkt | Windows 10 (22H2) | Windows 11 (23H2 und neuer) |
| --- | --- | --- |
| Support | Reguläre Updates seit dem 14.10.2025 beendet, nur noch über das ESU-Programm | Je nach Version bis zum jeweiligen Ende des Supports, Übersicht bei Microsoft |
| PowerShell | Windows PowerShell 5.1 enthalten | Windows PowerShell 5.1 enthalten, PowerShell 7 optional |
| TLS-Zeile (Schritt 2) | Nötig bei älteren Builds, sonst schlägt `Install-Module` fehl | Schadet nicht, meist unnötig |
| `winget` | Teils nicht vorhanden, Nachinstallation nötig | Meist vorhanden |
| Feature-Update | `setup.exe /auto upgrade …` aus der ISO | wie Windows 10; ISO siehe [Download-Links](../04_Rettungsmedien_und_Live_Systeme/04_Download_Links.md) |

Die Build-Nummer zeigt `winver`. Den Support-Zeitraum der installierten Version listet Microsoft unter <https://learn.microsoft.com/de-de/lifecycle/products/windows-11-home-and-pro>.

## 4. Feature- und Store-Updates erzwingen

Manchmal hängen App-Updates aus dem Microsoft Store oder Feature-Updates. So lassen sich diese anstoßen:

### 4.1 Microsoft Store Apps aktualisieren
```powershell
# Startet den Microsoft Store Update-Prozess für alle vorinstallierten und bezogenen Apps
Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod
```

### 4.2 Feature-Update / Upgrade steuern
Windows-Upgrades lassen sich per Windows Update Assistent oder per ISO steuern:

```cmd
:: ISO mounten und Upgrade ohne Nutzerinteraktion starten (Unattended)
setup.exe /auto upgrade /quiet /migratedrivers all /showoobe none /postoobe "C:\skript.bat"
```

## 5. Problembehandlung (Troubleshooting)

Wenn Windows Update hängt oder fehlschlägt:

> **Warnung:** Der Windows-Update-Cache sollte nicht direkt geloescht werden, solange Dienste laufen oder ein Update aktiv installiert. Erst Status pruefen, Ordner umbenennen und nach erfolgreicher Reparatur entfernen.

```powershell
# 1. Update-Dienst neu starten
Restart-Service -Name wuauserv

# 2. Hard-Reset von Windows Update (Dienste stoppen & Cache sichern)
Stop-Service wuauserv, bits -Force
Rename-Item "$env:windir\SoftwareDistribution" "SoftwareDistribution.bak"
Start-Service wuauserv, bits

# 3. Verifikation: Update-Suche erneut starten
UsoClient StartScan
Get-Service wuauserv, bits

# Rollback, falls der Reset nicht hilft
Stop-Service wuauserv, bits -Force
Remove-Item "$env:windir\SoftwareDistribution" -Recurse -Force
Rename-Item "$env:windir\SoftwareDistribution.bak" "SoftwareDistribution"
Start-Service wuauserv, bits

# 4. Fehlerhaftes Update manuell deinstallieren
wusa /uninstall /kb:1234567 /quiet
```

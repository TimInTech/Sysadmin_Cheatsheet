# 03 Systemreparatur und Wartung (Windows 11)

Befehle für die tiefgreifende Reparatur und Bereinigung von Windows 11. Alle Befehle erfordern Administratorrechte (CMD oder PowerShell).

## 1. Beschädigte Systemdateien reparieren

Wenn Windows instabil ist, sollten diese beiden Werkzeuge in Kombination verwendet werden:

### 1.1 DISM (Deployment Image Servicing and Management)
Repariert das lokale Windows-Image, welches als Grundlage für `sfc` dient. Benötigt eine Internetverbindung.
```cmd
:: Schritt 1: Image auf Fehler prüfen und reparieren
DISM /Online /Cleanup-Image /RestoreHealth
```

### 1.2 SFC (System File Checker)
Nachdem das Image per DISM repariert wurde, werden die lokalen Systemdateien geprüft und überschrieben.
```cmd
:: Schritt 2: Systemdateien scannen
sfc /scannow
```

### 1.3 Komponentenspeicher bereinigen
Löscht verwaiste Windows-Update-Komponenten und gibt Speicherplatz frei.
```cmd
DISM /Online /Cleanup-Image /StartComponentCleanup
```

## 2. Dateisystem und Festplatten

### 2.1 Chkdsk
Prüft das Dateisystem auf Fehler.
```cmd
:: Laufwerk C: scannen und Fehler beheben
chkdsk C: /f

:: Intensiver Oberflächen-Scan inkl. Fehlerbehebung (Dauert lange!)
chkdsk C: /f /r
```

### 2.2 Fsutil
Zeigt Informationen zum Dateisystem an und repariert Hardlinks.
```cmd
:: Dirty Bit des Dateisystems abfragen (prüft, ob das System unsauber heruntergefahren wurde)
fsutil dirty query C:
```

## 3. Automatisierte Bereinigung

Festplattenplatz freigeben, ohne durch grafische Menüs zu navigieren.

> **Warnung:** `del /s` löscht rekursiv und ohne Rueckfrage. Pfade vorher mit `dir` pruefen und wichtige Daten sichern.

### 3.1 Datenträgerbereinigung mit gespeichertem Profil

`cleanmgr /sagerun:1` führt nur die Aufgaben aus, die vorher mit `cleanmgr /sageset:1` ausgewählt wurden. Deshalb einmalig das Profil anlegen, danach läuft die Bereinigung ohne Fenster. Die Nummer `1` ist frei wählbar (0 bis 9999), muss aber bei beiden Aufrufen gleich sein. Quelle: [cleanmgr (Microsoft Learn)](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr). Nicht getestet.

```cmd
:: Einmalig als Administrator: Fenster oeffnet sich, gewuenschte Kategorien ankreuzen, OK
cleanmgr /sageset:1

:: Danach jederzeit: gespeichertes Profil 1 auf allen Laufwerken ausfuehren
cleanmgr /sagerun:1
```

### 3.2 Temporäre Dateien

```cmd
:: Pruefung: Inhalt vorher ansehen
dir %temp%

:: Temporaere Dateien loeschen (gesperrte Dateien bleiben stehen, das ist normal)
del /q /f /s %temp%\*
del /q /f /s C:\Windows\Temp\*

:: Verifikation
dir %temp%
```

### 3.3 Vorherige Windows-Installation (Windows.old)

> **Warnung:** Wer `Windows.old` löscht, kann nicht mehr zur vorherigen Windows-Version zurückkehren. Laut Microsoft lässt sich das nicht rückgängig machen. Vorher prüfen, ob die neue Version zuverlässig läuft.

Den Ordner nicht mit `rd` entfernen, sondern über den Weg, den Microsoft vorsieht: **Einstellungen → System → Speicher → Temporäre Dateien → „Vorherige Windows-Installation(en)“** ankreuzen und entfernen. Alternativ in der Datenträgerbereinigung über **Systemdateien bereinigen**. Quelle: [Speicherplatz freigeben (Microsoft Support)](https://support.microsoft.com/en-us/windows/free-up-drive-space-in-windows-85529ccb-c365-490d-b548-831022bc9b32). Menübezeichnungen nicht getestet.

```cmd
:: Pruefung: Ist Windows.old vorhanden?
dir %systemdrive%\Windows.old
```

Rollback: Ein entfernter `Windows.old`-Ordner lässt sich nur aus einem vorherigen Backup oder Systemimage wiederherstellen.

## 4. Häufige Alltagsprobleme schnell lösen

Manchmal hilft ein einfacher Konsolenbefehl, um nervige Bugs zu beseitigen, ohne den PC neu starten zu müssen.

### 4.1 Eingefrorener Windows-Explorer / Taskleiste hängt
Wenn der Desktop nicht mehr reagiert oder die Taskleiste verschwunden ist:
```powershell
# Explorer (die grafische Oberfläche) beenden und sofort neu starten
Stop-Process -Name explorer -Force; Start-Process explorer
```

### 4.2 Drucker streikt (Print Spooler)
Wenn Druckaufträge in der Warteschlange festhängen und sich nicht löschen lassen:

> **Warnung:** Der optionale `del /S`-Befehl löscht alle Dateien in der Druckerwarteschlange ohne Rueckfrage. Pfad vor dem Ausführen prüfen.

```cmd
:: Druckerwarteschlangendienst stoppen
net stop spooler

:: Backup der aktuellen Warteschlange fuer Analyse/Rollback
xcopy "%systemroot%\System32\Spool\Printers" "%temp%\Printers-Spool-Backup" /E /I /H

:: (Optional: Hängende Druckjobs manuell löschen)
del /Q /F /S "%systemroot%\System32\Spool\Printers\*.*"

:: Dienst wieder starten
net start spooler

:: Verifikation
dir "%systemroot%\System32\Spool\Printers"
```

Rollback: Falls ein Auftrag faelschlich geloescht wurde, Dateien aus `%temp%\Printers-Spool-Backup` zurueckkopieren und den Spooler erneut starten.

## 5. Erweiterte Diagnosen

### 5.1 WMI-Repository reparieren
Wenn Skripte oder System-Tools unerwartete Fehler werfen, kann das Windows Management Instrumentation (WMI) Repository beschädigt sein.
```cmd
:: Konsistenz prüfen
winmgmt /verifyrepository

:: Reparatur versuchen (rettet intakte Teile)
winmgmt /salvagerepository

:: Komplett zurücksetzen (Vorsicht, kann andere Apps beeinträchtigen!)
winmgmt /resetrepository
```

### 5.2 Event-Logs via PowerShell auslesen
Häufige Abstürze oder Fehler im System lassen sich am besten über das Windows Ereignisprotokoll (Event Viewer) nachvollziehen.
```powershell
# Die letzten 20 Fehler- und kritischen Einträge im System-Log anzeigen
Get-EventLog -LogName System -EntryType Error,Critical -Newest 20

# Nach einem bestimmten Fehlercode (z.B. EventID 1001 für Bluescreens) suchen
Get-EventLog -LogName System | Where-Object {$_.EventID -eq 1001} | Select-Object TimeGenerated, Message -First 5
```

### 5.3 Erweiterte Event-Abfrage mit Get-WinEvent

```powershell
# Kritische Fehler der letzten 7 Tage (schneller als Get-EventLog)
Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2; StartTime=(Get-Date).AddDays(-7)} |
  Select-Object TimeCreated, Id, ProviderName, Message -First 50

# Application-Events filtern
Get-WinEvent -FilterHashtable @{LogName='Application'; Level=1,2; StartTime=(Get-Date).AddDays(-7)} |
  Select-Object TimeCreated, Id, ProviderName, Message -First 50
```

### 5.4 Dienste und Tasks verwalten

```powershell
# Alle Dienste sortiert anzeigen
Get-Service | Sort-Object Status, Name

# Nur gestoppte Dienste anzeigen
Get-Service | Where-Object Status -eq 'Stopped'

# Nicht deaktivierte Scheduled Tasks anzeigen
Get-ScheduledTask | Where-Object State -ne 'Disabled' | Select-Object TaskName, TaskPath, State
```

## 6. Notfallmaßnahmen & Vorbereitung

### 6.1 Wiederherstellungspunkt setzen
Bevor riskante Skripte oder Änderungen ausgeführt werden:
```powershell
Checkpoint-Computer -Description "Manuelle Reparatur" -RestorePointType MODIFY_SETTINGS
```

### 6.2 Inplace-Upgrade vorbereiten
Wenn alles fehlschlägt und Windows repariert werden muss, ohne Daten zu verlieren:
```powershell
Reg.exe Add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion" /v AllowInplaceUpgrade /t REG_DWORD /f /d 1
```

### 6.3 PowerShell Ausführungsrichtlinien anpassen
Oft scheitern Reparaturskripte an fehlenden Rechten:
```powershell
# Eigene Rechte prüfen
whoami /priv

# Skriptausführung erlauben (RemoteSigned)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

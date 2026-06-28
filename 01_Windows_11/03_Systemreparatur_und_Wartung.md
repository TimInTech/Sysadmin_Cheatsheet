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

```cmd
:: Bereinigungswerkzeug aufrufen (Silent Mode)
cleanmgr /sagerun:1

:: Veraltete Windows-Installationen (Windows.old) sicher entfernen
rd /s /q %systemdrive%\Windows.old

:: Temporäre Dateien radikal löschen
del /q /f /s %temp%\*
del /q /f /s C:\Windows\Temp\*
```

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
```cmd
:: Druckerwarteschlangendienst stoppen
net stop spooler

:: (Optional: Hängende Druckjobs manuell löschen)
del /Q /F /S "%systemroot%\System32\Spool\Printers\*.*"

:: Dienst wieder starten
net start spooler
```

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

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

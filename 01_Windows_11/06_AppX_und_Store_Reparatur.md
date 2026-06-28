# AppX und Microsoft Store Reparatur

Probleme mit Windows 11 Standard-Apps (z. B. Taschenrechner, Fotos-App, Startmenü öffnet sich nicht) oder dem Microsoft Store selbst lassen sich häufig über die PowerShell beheben.

## 1. Microsoft Store reparieren

### Store-Cache zurücksetzen
Dies ist der einfachste und schnellste Schritt. Drücken Sie `Win + R` und führen Sie den Befehl aus (oder im Terminal):
```cmd
wsreset.exe
```
*(Das öffnet ein leeres Konsolenfenster, das sich nach dem Bereinigen des Caches automatisch schließt und den Store startet).*

### Store neu registrieren (PowerShell als Admin)
Falls der Store komplett fehlt oder sofort abstürzt:
```powershell
Get-AppXPackage *WindowsStore* -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
```

## 2. Alle Standard-Apps neu registrieren

Wenn das Startmenü hängt, die Suche nicht funktioniert oder mehrere integrierte Apps streiken, können alle Apps für den aktuellen Benutzer neu registriert werden:
```powershell
Get-AppXPackage -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
```
*(Hinweis: Hierbei treten rote Fehlermeldungen auf für Apps, die gerade in Benutzung sind – diese können sicher ignoriert werden).*

## 3. Entfernte Standard-Apps wiederherstellen

Wenn Apps (Bloatware) zuvor per Skript deinstalliert wurden und nun doch eine System-App (wie Xbox Game Bar oder Snipping Tool) benötigt wird, suchen Sie das entsprechende Paket:

**Pakete auflisten (die nicht installiert, aber im System-Image vorhanden sind):**
```powershell
Get-AppxProvisionedPackage -Online | Select-Object DisplayName, PackageName
```

**Eine spezifische App wiederherstellen (Beispiel: Snipping Tool):**
```powershell
Add-AppxPackage -Register -DisableDevelopmentMode "C:\Program Files\WindowsApps\Microsoft.ScreenSketch_*\AppxManifest.xml"
```
*(Der Pfad variiert leicht je nach Version, verwenden Sie die Tab-Vervollständigung in der PowerShell).*

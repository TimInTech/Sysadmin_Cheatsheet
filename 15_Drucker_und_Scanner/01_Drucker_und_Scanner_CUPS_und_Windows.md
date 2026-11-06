# 01 Drucker und Scanner: CUPS (Linux) und Windows

Die meisten Netzwerkdrucker aus den letzten Jahren sprechen **IPP** (Internet Printing Protocol). Das bedeutet: Sie brauchen unter Linux und Windows keinen eigenen Treiber, der Computer fragt den Drucker einfach nach seinen Fähigkeiten ("driverless"). Diese Seite zeigt, wie du Drucker einrichtest, Druckaufträge steuerst, hängende Warteschlangen löst und Scanner nutzt.

> **Hinweis:** Die Linux-Befehle sind auf einem Ubuntu-Rechner mit CUPS gegen die Hilfe der Programme und einen echten Netzwerkdrucker geprüft (Status, Geräteliste). Es wurde nicht gedruckt oder gescannt. Windows-Befehle sind gegen Microsoft Learn geprüft, aber *nicht getestet*. Ersetze `DRUCKER`, `DRUCKERNAME` durch den Namen deines Druckers und `HOST` durch Name oder Adresse des Druckers.

> **Warnung:** Löschen der Warteschlange (`cancel -a`, Spooler-Ordner leeren) wirft **alle** offenen Aufträge weg. Passwörter für Drucker-Weboberflächen gehören nicht in Befehle oder Skripte.

## 1. Linux: Drucker einrichten (CUPS)

Ubuntu bringt CUPS mit. Meist erkennt der Rechner Netzwerkdrucker von selbst: **Einstellungen -> Drucker**.

### Status prüfen

```bash
# Läuft der Druckdienst?
systemctl status cups --no-pager

# Alle Drucker, Standarddrucker, Aufträge, Anschlüsse
lpstat -t
lpstat -p -d
lpstat -v
```

### Drucker finden und einrichten (ohne Treiber)

```bash
# Vom Drucker angebotene Verbindungen im Netz auflisten
lpinfo -v

# Drucker, die ohne Treiber (IPP Everywhere) funktionieren
driverless
```

Aus der Ausgabe von `driverless` die Adresse (z. B. `ipps://HOST.local:631/ipp/print`) kopieren. Einrichten:

```bash
sudo lpadmin -p DRUCKERNAME -E -v "ipps://HOST.local:631/ipp/print" -m everywhere
```

`-p` vergibt den Namen (ohne Leerzeichen), `-E` aktiviert und gibt den Drucker frei, `-v` ist die Adresse, `-m everywhere` nimmt den treiberlosen Modus. Die Optionen stehen in der [lpadmin-Dokumentation](https://www.cups.org/doc/man-lpadmin.html). Zum Standarddrucker machen:

```bash
sudo lpadmin -d DRUCKERNAME
```

Entfernen (Rollback):

```bash
sudo lpadmin -x DRUCKERNAME
```

Nur wenn der Drucker alt ist und kein IPP kann, brauchst du einen Hersteller-Treiber: HP-Drucker über `hplip` (`sudo apt install hplip`, danach `hp-setup`), sonst `sudo apt install printer-driver-all` und mit `lpinfo -m` das passende Modell suchen. Nicht getestet.

### Drucken und Optionen

```bash
# Datei drucken
lp -d DRUCKERNAME datei.pdf

# 2 Kopien, beidseitig (lange Kante), Format A4
lp -d DRUCKERNAME -n 2 -o sides=two-sided-long-edge -o media=A4 datei.pdf

# Nur bestimmte Seiten
lp -d DRUCKERNAME -o page-ranges=1-3 datei.pdf

# Welche Optionen kennt der Drucker?
lpoptions -p DRUCKERNAME -l
```

### Warteschlange verwalten

```bash
# Aufträge anzeigen
lpstat -o

# Einzelnen Auftrag abbrechen (ID aus lpstat -o)
cancel DRUCKERNAME-12

# Alle Aufträge dieses Druckers abbrechen
cancel -a DRUCKERNAME

# Drucker anhalten und wieder freigeben
sudo cupsdisable DRUCKERNAME
sudo cupsenable DRUCKERNAME
```

## 2. Linux: Fehlersuche beim Drucken

| Problem | Prüfen |
| --- | --- |
| Drucker nicht gefunden | Drucker und Rechner im selben (WLAN-)Netz? `ping HOST`, `lpinfo -v` |
| Auftrag hängt "in Warteschlange" | `lpstat -o`, `lpstat -p` zeigt "deaktiviert"? Dann `sudo cupsenable DRUCKERNAME` |
| Seiten bleiben leer / Zeichenmüll | Treiberlos (`-m everywhere`) statt Herstellertreiber probieren |
| Drucker nach Neustart weg | Name geändert? `lpstat -t`, Adresse per `lpadmin -v` erneuern |
| Nach Update druckt nichts | `sudo systemctl restart cups`, Logs: `journalctl -u cups -n 50 --no-pager` |

Die Weboberfläche von CUPS erreichst du unter `http://localhost:631`. Sie ist nur lokal erreichbar. Gib den CUPS-Dienst nicht ins Internet frei. Den Freigabestatus zeigt `cupsctl` (bei Standard: `_remote_any=0`, `_share_printers=0`).

## 3. Windows: Drucker einrichten

Einfach: **Einstellungen -> Bluetooth und Geräte -> Drucker und Scanner -> Gerät hinzufügen**. Windows 10/11 findet IPP-Drucker meist selbst und installiert den "Microsoft IPP Class Driver".

Per PowerShell (als Administrator):

```powershell
# Alle Drucker und ihr Status
Get-Printer | Select-Object Name, DriverName, PortName, PrinterStatus

# Netzwerkport für die Adresse des Druckers anlegen
Add-PrinterPort -Name "IP_HOST" -PrinterHostAddress "HOST"

# Drucker mit dem eingebauten Treiber hinzufügen
Add-Printer -Name "DRUCKERNAME" -DriverName "Microsoft IPP Class Driver" -PortName "IP_HOST"
```

Ob der Treibername auf deinem Windows so heißt, zeigt `Get-PrinterDriver`. Nicht getestet. Die Befehle sind unter [Add-Printer](https://learn.microsoft.com/de-de/powershell/module/printmanagement/add-printer), [Add-PrinterPort](https://learn.microsoft.com/de-de/powershell/module/printmanagement/add-printerport) und [Get-Printer](https://learn.microsoft.com/de-de/powershell/module/printmanagement/get-printer) beschrieben.

Standarddrucker und Entfernen:

```powershell
(New-Object -ComObject WScript.Network).SetDefaultPrinter("DRUCKERNAME")
Remove-Printer -Name "DRUCKERNAME"
```

## 4. Windows: Druckwarteschlange hängt

Einzelne Aufträge ansehen und löschen:

```powershell
Get-PrintJob -PrinterName "DRUCKERNAME"
Remove-PrintJob -PrinterName "DRUCKERNAME" -ID 3
```

Wenn die Warteschlange gar nicht mehr reagiert, Spooler zurücksetzen (Administrator):

```powershell
Stop-Service -Name Spooler -Force
Remove-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*" -Force
Start-Service -Name Spooler
```

> **Warnung:** Das löscht alle offenen Druckaufträge für alle Drucker. Der Ordner selbst bleibt erhalten. Nicht getestet. Mehr: [Get-PrintJob](https://learn.microsoft.com/de-de/powershell/module/printmanagement/get-printjob), [Remove-PrintJob](https://learn.microsoft.com/de-de/powershell/module/printmanagement/remove-printjob).

Hilft das nicht: Drucker entfernen, neu hinzufügen, Windows-Updates einspielen ([Update und Upgrade](../01_Windows_11/01_Update_und_Upgrade.md)), Dienste prüfen ([PowerShell-Diagnose](../01_Windows_11/10_PowerShell_Diagnose.md)).

## 5. Scanner unter Linux (SANE)

Die meisten WLAN-Multifunktionsgeräte scannen über das Netzwerk (eSCL/AirScan). Dafür gibt es das Paket `sane-airscan`.

```bash
sudo apt install sane-utils sane-airscan simple-scan

# Gefundene Scanner anzeigen
scanimage -L
```

Bleibt die Ausgabe leer ("No scanners were identified"), prüfe Netz, Strom und ob der Scanner im Drucker-Menü eingeschaltet ist. Dann ein Bild scannen. `DEVICE` ist die Kennung aus `scanimage -L`:

```bash
scanimage -d "DEVICE" --format=png --resolution 300 --mode Color -o scan.png -p
```

Die Optionen (`--format`, `--resolution`, `--mode`, `-o`, `-p`) stehen in `scanimage --help`. Welche Werte dein Gerät erlaubt, zeigt `scanimage -d "DEVICE" --help`. Mehrere Seiten im Stapel (Einzug): `--batch` mit `--format=tiff`. Für Einsteiger gibt es die grafische Anwendung **Einfaches Scannen** (`simple-scan`). Dokumentation: [SANE](https://sane-project.gitlab.io/website/) und [sane-airscan](https://github.com/alexpevzner/sane-airscan). Das Scannen selbst ist *nicht getestet*.

## 6. Scanner unter Windows

Nutze die App **Windows-Scan** aus dem Microsoft Store, sie spricht mit den meisten Geräten ohne Zusatztreiber. Bei Netzwerkgeräten findet Windows den Scanner zusammen mit dem Drucker. Wenn nicht, hilft die Hersteller-App (HP Smart, Epson Scan, Canon IJ Scan Utility). Hersteller-Software lädst du nur von der offiziellen Seite des Herstellers.

## 7. Sicherheit und Pflege

- Weboberfläche des Druckers mit eigenem Passwort schützen (Werkseinstellung ändern).
- Drucker nicht im Router ins Internet freigeben (Ports 631, 9100 bleiben zu).
- Firmware-Updates des Herstellers einspielen.
- Drucker-Passwort und Netzwerkschlüssel nicht in Notizen oder Repositories speichern.

## Quellen

- [lpadmin (CUPS)](https://www.cups.org/doc/man-lpadmin.html)
- [OpenPrinting CUPS](https://openprinting.github.io/cups/)
- [SANE-Projekt](https://sane-project.gitlab.io/website/)
- [sane-airscan](https://github.com/alexpevzner/sane-airscan)
- [PrintManagement-Modul (Microsoft Learn)](https://learn.microsoft.com/de-de/powershell/module/printmanagement/)

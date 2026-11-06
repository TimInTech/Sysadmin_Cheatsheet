# 01 Ersteinrichtung nach der Neuinstallation (Windows und Ubuntu)

Diese Checkliste führt dich in fester Reihenfolge durch die ersten Stunden mit einem frisch installierten Rechner. Die Reihenfolge ist wichtig: Erst Updates und Treiber, dann Sicherheit, dann Programme, dann Feinschliff. So musst du nichts doppelt machen.

> **Hinweis:** Die Befehle wurden gegen die Hilfe der Werkzeuge unter Ubuntu und die winget-Paketliste geprüft. Windows-Befehle konnten auf dem Ubuntu-Testrechner nicht ausgeführt werden und sind als *nicht getestet* gekennzeichnet, wo sie neu sind. Die bewährten Windows-Update-Befehle stehen unter [Update und Upgrade](../01_Windows_11/01_Update_und_Upgrade.md).

> **Warnung:** Die Schritte 1 bis 3 ändern Systemeinstellungen. Notiere dir vorher den Recovery-Key von BitLocker bzw. das Passwort der Festplattenverschlüsselung. Ohne diese Daten kommst du nach einem Fehler nicht mehr an deine Dateien.

## Die Reihenfolge auf einen Blick

| Schritt | Windows | Ubuntu |
| --- | --- | --- |
| 1 | Updates und Treiber | Updates und Treiber |
| 2 | Name, Konto, Zeit, Sprache | Name, Zeit, Sprache, Tastatur |
| 3 | Sicherheit (Defender, BitLocker, Firewall) | Sicherheit (Firewall, automatische Updates) |
| 4 | Programme per winget | Programme per apt, Snap, Flatpak |
| 5 | Datensicherung einrichten | Datensicherung einrichten |
| 6 | Fernzugriff (SSH) | Fernzugriff (SSH) |
| 7 | Prüfen und Wiederherstellungspunkt | Prüfen und Snapshot |

## 1. Updates und Treiber

Immer zuerst, mit Internetverbindung. Danach neu starten.

### Windows (Updates und Treiber)

Alle Updates und Treiber in einem Durchlauf: [Windows komplett aktualisieren](../01_Windows_11/01_Update_und_Upgrade.md#1-nach-der-neuinstallation-alles-in-einem-durchlauf). Danach zusätzlich Hersteller-Treiber (Grafik, Chipsatz) von der Seite des Herstellers, falls Windows Update keine passenden findet. Links: [Download-Links](../04_Rettungsmedien_und_Live_Systeme/04_Download_Links.md).

### Ubuntu (Updates und Treiber)

```bash
# Paketlisten aktualisieren und alles einspielen
sudo apt update && sudo apt full-upgrade -y

# Snaps aktualisieren
sudo snap refresh

# Passende Treiber anzeigen (z. B. NVIDIA) und installieren
ubuntu-drivers devices
sudo ubuntu-drivers install

# Firmware-Updates des Herstellers (Mainboard, SSD, Dockingstation)
sudo fwupdmgr refresh
sudo fwupdmgr get-updates
sudo fwupdmgr update

# Neustart
sudo reboot
```

`ubuntu-drivers install` ohne Angabe wählt den empfohlenen Treiber. Wer ihn selbst wählen will, listet erst mit `ubuntu-drivers list` die Pakete auf. Bei einem Rechner mit Secure Boot fragt Ubuntu bei NVIDIA-Treibern nach einem Passwort für die Schlüsselregistrierung (MOK) und verlangt nach dem Neustart eine Bestätigung im blauen Bildschirm. Das Passwort merken. Nicht getestet.

## 2. Name, Zeit, Sprache

### Windows (Name, Zeit, Sprache)

1. **Einstellungen -> System -> Info -> Diesen PC umbenennen**: einen kurzen Namen ohne Leerzeichen wählen.
2. **Einstellungen -> Zeit und Sprache**: Zeitzone und Region prüfen.
3. Benutzerkonto: ein normales Konto für den Alltag, nicht das Administratorkonto. Nähere Befehle: [Benutzer und Rechteverwaltung](../01_Windows_11/05_Benutzer_und_Rechteverwaltung.md).

```powershell
# Computername ändern (neu starten danach, PCNAME ersetzen)
Rename-Computer -NewName "PCNAME" -Force
```

Nicht getestet.

### Ubuntu (Name, Zeit, Sprache)

```bash
# Rechnername setzen (PCNAME ersetzen)
sudo hostnamectl set-hostname PCNAME

# Zeitzone setzen und automatische Zeit einschalten
sudo timedatectl set-timezone Europe/Berlin
sudo timedatectl set-ntp true

# Tastaturbelegung deutsch setzen
sudo localectl set-x11-keymap de

# Prüfen
hostnamectl
timedatectl
```

Weitere Hinweise zur Belegung: [Tastaturbelegung DE/UK](../02_Linux/29_Tastaturbelegung_DE_UK.md).

## 3. Sicherheit

### Windows (Sicherheit)

1. **Windows-Sicherheit** öffnen und alle Bereiche auf grün bringen (Viren- und Bedrohungsschutz, Firewall).
2. **BitLocker** bzw. Geräteverschlüsselung einschalten, wenn der Rechner ein Laptop ist. Recovery-Key **nicht** auf demselben Rechner speichern. Anleitung: [BitLocker und TPM](../01_Windows_11/09_BitLocker_und_TPM.md).
3. Ein starkes Anmeldepasswort oder Windows Hello (PIN) einrichten.

```powershell
# Status prüfen
Get-MpComputerStatus | Select-Object AntivirusEnabled, RealTimeProtectionEnabled
Get-NetFirewallProfile | Select-Object Name, Enabled
```

Nicht getestet.

### Ubuntu (Sicherheit)

```bash
# Firewall: eingehend alles sperren, ausgehend erlauben, dann einschalten
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

# Status
sudo ufw status verbose

# Automatische Sicherheitsupdates prüfen (bei Ubuntu normalerweise schon aktiv)
cat /etc/apt/apt.conf.d/20auto-upgrades
systemctl status unattended-upgrades --no-pager
```

> **Warnung:** Wenn du per SSH an diesem Rechner arbeitest, erlaube SSH **vor** `ufw enable`: `sudo ufw allow OpenSSH`. Sonst sperrst du dich aus. Mehr dazu: [Netzwerk und Dienste](../02_Linux/03_Netzwerk_und_Dienste.md).

Bei Ubuntu verschlüsselt der Installer die Festplatte nur, wenn du das bei der Installation ausgewählt hast. Nachträglich ist das nicht ohne Neuinstallation möglich.

## 4. Programme installieren

### Windows: Paketliste mit winget

Die Datei [programme.winget.json](programme.winget.json) in diesem Ordner enthält eine Auswahl nützlicher Programme:

| Programm | Zweck |
| --- | --- |
| Firefox, Thunderbird | Browser und E-Mail |
| VLC | Videos und Musik |
| 7-Zip | ZIP- und andere Archive |
| Notepad++, VS Code | Texteditor und Code-Editor |
| LibreOffice | Office-Paket |
| KeePassXC | Passwortmanager |
| Git | Versionsverwaltung |
| PowerToys | Windows-Zusatzwerkzeuge |
| Rufus | Bootfähige USB-Sticks |
| HWiNFO, CrystalDiskInfo | Hardware- und Festplattenstatus |
| Platform-Tools, scrcpy | Android-Handy am Computer (Android-Anleitung folgt in `10_Android`) |

Zum Importieren (PowerShell, im Ordner der Datei oder mit vollem Pfad):

```powershell
# Datei vorher prüfen und unerwünschte Zeilen löschen
notepad .\programme.winget.json

# Importieren, ohne Rückfragen
winget import -i .\programme.winget.json --accept-source-agreements --accept-package-agreements
```

Einzelne Programme, die winget nicht findet oder nicht installieren kann, meldet der Befehl am Ende. Er läuft trotzdem weiter. Installationen brauchen teilweise Administratorrechte (Bestätigung per Fenster). Alle Paket-IDs wurden im offiziellen `winget-pkgs`-Verzeichnis geprüft. Der Import selbst ist unter Windows *nicht getestet*.

Den Stand deines Rechners später als eigene Liste speichern:

```powershell
winget export -o .\meine-programme.json
```

Mehr zu winget: [Standardsoftware Deployment](../01_Windows_11/02_Standardsoftware_Deployment.md).

### Ubuntu (Programme installieren)

```bash
# Grundausstattung
sudo apt install -y curl wget git htop ncdu tree vlc keepassxc 7zip libreoffice

# Flatpak für Programme, die nicht im Archiv sind (Beispiel)
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Android-Werkzeuge
sudo apt install -y adb scrcpy
```

Firefox und Thunderbird sind bei Ubuntu 26.04 bereits als Snap vorhanden (siehe [Ubuntu 26.04 Neuerungen](../02_Linux/27_Ubuntu_26-04_Neuerungen_und_Anwendungen.md)). Das Paket `7zip` ersetzt bei neueren Ubuntu-Versionen `p7zip-full`. Falls die Paketnamen bei dir abweichen, suche mit `apt search NAME`.

## 5. Datensicherung einrichten

Eine Neuinstallation ist der beste Zeitpunkt, sofort ein Backup einzurichten.

1. Wichtige Daten nur auf **einem** Ort speichern, den du sichern kannst (z. B. Ordner `Dokumente`).
2. Backup auf ein **externes Laufwerk** oder ein NAS, getrennt vom Rechner.
3. **Wiederherstellung einmal testen**, sonst weißt du nicht, ob die Sicherung funktioniert.

Windows: **Einstellungen -> Konten -> Windows-Sicherung** oder Dateiversionsverlauf. Ubuntu: [restic](../02_Linux/10_Backup_mit_Restic.md), [BorgBackup](../02_Linux/19_BorgBackup.md) oder [rsync](../02_Linux/18_rsync.md).

## 6. Fernzugriff per SSH

Wenn du den Rechner später von einem anderen aus bedienen willst, nutze das einfache [SSH-Toolkit](../toolkit/README.md). Windows im Detail: [OpenSSH-Server und Ubuntu-Zugriff](../01_Windows_11/11_OpenSSH_Server_Ubuntu_Zugriff.md). Ubuntu: [SSH und Remote-Zugriff](../02_Linux/04_SSH_und_Remote_Zugriff.md).

## 7. Abschlusskontrolle

### Windows (Abschlusskontrolle)

```powershell
# Windows-Version und Aktivierung
winver
slmgr /xpr

# Datenträger-Gesundheit
Get-PhysicalDisk | Select-Object FriendlyName, HealthStatus, OperationalStatus

# Wiederherstellungspunkt anlegen (Systemschutz muss für C: aktiv sein)
Checkpoint-Computer -Description "Nach Ersteinrichtung" -RestorePointType MODIFY_SETTINGS
```

Nicht getestet. Falls `Checkpoint-Computer` meldet, der Systemschutz sei aus: **Systemsteuerung -> Wiederherstellung -> Systemwiederherstellung konfigurieren**.

### Ubuntu (Abschlusskontrolle)

```bash
# Version, Kernel, Neustart nötig?
lsb_release -a
uname -r
test -f /var/run/reboot-required && echo "Neustart nötig" || echo "kein Neustart nötig"

# Datenträger und Speicher
lsblk -f
df -h /
```

Ein Snapshot (z. B. mit Timeshift oder Proxmox, falls virtuell) sichert diesen sauberen Zustand. Bei einer VM auf Proxmox: [Proxmox VE](../05_Proxmox_VE/02_VM_QM_Befehle.md).

Danach ist der Rechner einsatzbereit.

## Quellen

- [winget-Dokumentation](https://learn.microsoft.com/de-de/windows/package-manager/winget/)
- [winget import](https://learn.microsoft.com/de-de/windows/package-manager/winget/import)
- [winget-pkgs (Paket-IDs)](https://github.com/microsoft/winget-pkgs)
- [Ubuntu: Automatische Updates](https://documentation.ubuntu.com/server/how-to/software/automatic-updates/)
- [Ubuntu: Treiber installieren](https://documentation.ubuntu.com/server/how-to/graphics/install-nvidia-drivers/)

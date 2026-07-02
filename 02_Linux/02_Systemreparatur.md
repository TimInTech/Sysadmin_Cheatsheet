# 02 Systemreparatur (Linux)

Diese Befehle helfen, wenn das System nicht mehr startet, Updates hängen bleiben oder Dateisystemfehler auftreten.

## 1. Paketverwaltung reparieren

Oft bricht ein Update (z.B. durch Stromausfall oder volle Festplatte) ab. Dadurch wird die `dpkg`-Datenbank gesperrt oder beschädigt.

> **Warnung:** `rm -rf` löscht rekursiv ohne Papierkorb. Den Pfad exakt prüfen und keine Platzhalter ungeprüft erweitern.

```bash
# Schritt 1: Abgebrochene Konfigurationen abschließen
sudo dpkg --configure -a

# Schritt 2: Fehlende Abhängigkeiten auflösen und kaputte Installationen reparieren
sudo apt --fix-broken install

# Wenn ein Paket komplett "klemmt", Cache leeren und Paketlisten neu einlesen
sudo rm -rf /var/lib/apt/lists/*
sudo apt update

# Verifikation
sudo apt check
```

Rollback: Der geloeschte Paketlisten-Cache wird durch `sudo apt update` neu aufgebaut. Falls APT danach weiter fehlschlaegt, Paketquellen unter `/etc/apt/sources.list*` aus Backup oder Versionsverwaltung wiederherstellen.

## 2. Grub-Bootloader reparieren

Wenn Linux nicht bootet, muss oft Grub neu in den MBR oder die EFI-Partition geschrieben werden (meist aus einer Live-/Chroot-Umgebung heraus).

> **Warnung:** Bootloader-Reparaturen können das System oder Dual-Boot-Setups unbootbar machen. Vorher Bootmodus, Zielplatte und EFI-Partition prüfen (`lsblk -f`, `blkid`, `efibootmgr -v`) und ein Backup/Snapshot/Image bereithalten.

```bash
# Backup der aktuellen UEFI-Boot-Eintraege und EFI-Dateien, falls UEFI genutzt wird
sudo efibootmgr -v | sudo tee /root/efibootmgr-before.txt
sudo tar -czf /root/efi-backup.tgz /boot/efi/EFI

# Grub auf Laufwerk /dev/sda installieren (MBR / BIOS-Modus)
sudo grub-install /dev/sda

# Grub-Konfiguration neu generieren (erkennt andere Betriebssysteme wie Windows)
sudo update-grub

# Verifikation
sudo grub-install --version
sudo efibootmgr -v
```

Rollback: Bei UEFI die gesicherten EFI-Dateien aus `/root/efi-backup.tgz` zurueckspielen und Boot-Eintraege anhand `/root/efibootmgr-before.txt` wieder anlegen. Bei MBR/BIOS ist ein vorheriges Datentraegerimage der belastbare Rueckweg.

## 3. Dateisystem-Checks (fsck)

Überprüft Dateisysteme auf Konsistenz und repariert sie. **Wichtig: Das Dateisystem darf nicht eingehängt (mounted) sein, wenn es repariert wird!**

> **Warnung:** `fsck -y` bestätigt Reparaturen automatisch und kann beschädigte Daten endgültig verändern. Erst ein Image oder Backup erstellen, das richtige Gerät mit `lsblk -f` prüfen und nach Möglichkeit zuerst ohne `-y` diagnostizieren.

```bash
# Backup/Image vor Reparatur, Zielpfad anpassen
sudo ddrescue -f -n /dev/sda1 /mnt/backup/sda1.img /mnt/backup/sda1.map

# Partition erzwingen zu überprüfen und automatisch reparieren (Standard ext4)
sudo fsck -y /dev/sda1

# Verifikation
sudo fsck -n /dev/sda1
```

Rollback: Dateisystem-Reparaturen lassen sich nicht sinnvoll rueckgaengig machen. Bei Verschlechterung aus dem vorher erstellten Image weiterarbeiten oder das Image auf Ersatzmedium zurueckschreiben.

### Spezifisch für BTRFS
Wenn BTRFS (z.B. oft in openSUSE oder neuerdings Ubuntu-Installationen) verwendet wird, nutzt man nicht `fsck`.

> **Warnung:** `btrfs check --repair` ist eine Notfalloption und kann ein Dateisystem weiter beschädigen. Vorher Backup/Image erstellen, `btrfs scrub` und `btrfs check` ohne `--repair` prüfen und Subvolumes beachten.

```bash
# Dateisystem überprüfen (kann im laufenden Betrieb (mounted) erfolgen)
sudo btrfs scrub start /

# Status der Überprüfung anzeigen
sudo btrfs scrub status /

# Fehlerkorrektur bei unmounted Filesystem
sudo btrfs check --repair /dev/sda1

# Verifikation
sudo btrfs check /dev/sda1
```

Rollback: `btrfs check --repair` hat keinen sicheren Undo-Pfad. Der Rueckweg ist ein vorab erstelltes Image oder Backup.

## 4. Eingefrorene UI und Alltags-Bugs

Wenn der Linux-Desktop streikt oder Geräte spinnen, helfen diese schnellen Befehle, ohne direkt rebooten zu müssen (z.B. indem man auf ein anderes TTY via `Ctrl+Alt+F2` wechselt).

### 4.1 Grafische Oberfläche (GUI) ist komplett eingefroren
Startet den Display-Manager und somit die komplette grafische Sitzung neu (schließt alle grafischen Programme!).
```bash
# Für Kubuntu / KDE (sddm)
sudo systemctl restart sddm

# Für Ubuntu / GNOME (gdm3)
sudo systemctl restart gdm3

# Für LightDM (XFCE / Linux Mint)
sudo systemctl restart lightdm
```

### 4.2 Ein Programm lässt sich nicht schließen (Kill)
Wenn ein Programm abgestürzt ist und das rote X nicht funktioniert.
```bash
# Schritt 1: Finde die Prozess-ID (PID) anhand des Namens (z.B. firefox)
ps aux | grep firefox

# Schritt 2: Schieße den Prozess gnadenlos ab (ersetze 1234 mit der PID)
kill -9 1234
```

### 4.3 Kein Ton / Audio-Bugs
Sound verschwunden oder knistert? Ein Neustart des Audio-Servers hilft fast immer.
```bash
# Bei älteren Systemen mit PulseAudio (Ohne sudo!)
systemctl --user restart pulseaudio

# Bei neueren Systemen mit PipeWire (z.B. Ubuntu 22.10+) (Ohne sudo!)
systemctl --user restart pipewire pipewire-pulse
```

### 4.4 USB-Stick / Hardware wird nicht erkannt
```bash
# Live-Kernel-Logs anzeigen (Hilft enorm beim Einstecken von USB-Geräten, um zu sehen, was passiert)
sudo dmesg -w

# Alle angeschlossenen USB-Geräte auflisten
lsusb

# Alle PCI-Geräte (WLAN-Karten, Grafikkarten) auflisten
lspci
```

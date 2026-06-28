# 02 Systemreparatur (Linux)

Diese Befehle helfen, wenn das System nicht mehr startet, Updates hängen bleiben oder Dateisystemfehler auftreten.

## 1. Paketverwaltung reparieren

Oft bricht ein Update (z.B. durch Stromausfall oder volle Festplatte) ab. Dadurch wird die `dpkg`-Datenbank gesperrt oder beschädigt.

```bash
# Schritt 1: Abgebrochene Konfigurationen abschließen
sudo dpkg --configure -a

# Schritt 2: Fehlende Abhängigkeiten auflösen und kaputte Installationen reparieren
sudo apt --fix-broken install

# Wenn ein Paket komplett "klemmt", Cache leeren und Paketlisten neu einlesen
sudo rm -rf /var/lib/apt/lists/*
sudo apt update
```

## 2. Grub-Bootloader reparieren

Wenn Linux nicht bootet, muss oft Grub neu in den MBR oder die EFI-Partition geschrieben werden (meist aus einer Live-/Chroot-Umgebung heraus).

```bash
# Grub auf Laufwerk /dev/sda installieren (MBR / BIOS-Modus)
sudo grub-install /dev/sda

# Grub-Konfiguration neu generieren (erkennt andere Betriebssysteme wie Windows)
sudo update-grub
```

## 3. Dateisystem-Checks (fsck)

Überprüft Dateisysteme auf Konsistenz und repariert sie. **Wichtig: Das Dateisystem darf nicht eingehängt (mounted) sein, wenn es repariert wird!**

```bash
# Partition erzwingen zu überprüfen und automatisch reparieren (Standard ext4)
sudo fsck -y /dev/sda1
```

### Spezifisch für BTRFS
Wenn BTRFS (z.B. oft in openSUSE oder neuerdings Ubuntu-Installationen) verwendet wird, nutzt man nicht `fsck`.
```bash
# Dateisystem überprüfen (kann im laufenden Betrieb (mounted) erfolgen)
sudo btrfs scrub start /

# Status der Überprüfung anzeigen
sudo btrfs scrub status /

# Fehlerkorrektur bei unmounted Filesystem
sudo btrfs check --repair /dev/sda1
```

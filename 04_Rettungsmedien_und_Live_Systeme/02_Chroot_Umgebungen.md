# 02 Chroot Umgebungen (Linux)

Wenn ein Linux-System nicht mehr bootet (z.B. weil der Grub-Bootloader defekt ist oder das System bei einem Kernel-Update abgestürzt ist), ist `chroot` (Change Root) die einzige Rettung.

Mit `chroot` bootest du ein funktionierendes Live-Linux vom USB-Stick und "springst" über die Kommandozeile virtuell in dein kaputtes, installiertes Linux hinein. Dort hast du dann Root-Rechte und kannst Befehle so ausführen, als hättest du das kaputte System normal gestartet.

## 1. Schritt-für-Schritt in die Chroot-Umgebung

Angenommen, du hast ein Ubuntu/Mint Live-System gebootet. Deine kaputte Linux-Installation befindet sich auf der Festplattenpartition `/dev/sda2` und deine EFI-Boot-Partition (falls vorhanden) auf `/dev/sda1`.

### Schritt 1: Das kaputte System mounten
Zuerst hängen wir die Partition des kaputten Systems ins Dateisystem des Live-Sticks ein.
```bash
# Root-Partition in /mnt mounten
sudo mount /dev/sda2 /mnt
```

### Schritt 2: Spezielle virtuelle Dateisysteme durchreichen (WICHTIG!)
Damit Befehle wie `grub-install` oder `apt` funktionieren, müssen sie mit dem echten Kernel und der echten Hardware kommunizieren können. Daher binden wir `/dev`, `/proc` und `/sys` durch.
```bash
sudo mount --bind /dev /mnt/dev
sudo mount --bind /dev/pts /mnt/dev/pts
sudo mount --bind /proc /mnt/proc
sudo mount --bind /sys /mnt/sys
```

### Schritt 3: EFI-Partition mounten (Nur bei UEFI-Systemen)
Wenn das kaputte System UEFI nutzt (was heute Standard ist), muss auch die EFI-Partition in das kaputte System gemountet werden.
```bash
sudo mount /dev/sda1 /mnt/boot/efi
```

### Schritt 4: Chroot ausführen
Jetzt wechseln wir das Root-Verzeichnis.
```bash
sudo chroot /mnt /bin/bash
```
*Tipp: Der Prompt ändert sich nun (oft zu `root@live-usb:/#`). Du bist jetzt in deinem kaputten System!*

## 2. Reparaturen in der Chroot durchführen

Jetzt kannst du das System reparieren:

### 2.1 Grub (Bootloader) reparieren
```bash
# Grub neu in den MBR / EFI schreiben (Je nach BIOS/UEFI)
grub-install /dev/sda

# Konfiguration neu generieren
update-grub
```

### 2.2 Abgebrochene Updates reparieren
```bash
# Hängende Konfigurationen abschließen
dpkg --configure -a

# Pakete reparieren
apt --fix-broken install
apt update && apt upgrade
```

### 2.3 Passwörter zurücksetzen
```bash
# Dein vergessenes Root- oder User-Passwort ändern
passwd
passwd mein_benutzername
```

## 3. Chroot sauber verlassen

Wenn die Reparatur abgeschlossen ist, muss die Umgebung sauber abgebaut werden.

```bash
# 1. Chroot verlassen
exit
# (Du bist jetzt wieder im Live-System)

# 2. Laufwerke sicher unmounten
sudo umount /mnt/boot/efi   # (Falls gemountet)
sudo umount /mnt/sys
sudo umount /mnt/proc
sudo umount /mnt/dev/pts
sudo umount /mnt/dev
sudo umount /mnt

# 3. System neustarten
sudo reboot
```

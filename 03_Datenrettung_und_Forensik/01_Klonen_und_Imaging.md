# 01 Klonen und Imaging

Das absolut Wichtigste bei beschädigten Datenträgern (Klackern, defekte Sektoren, unabsichtliches Löschen) ist es, **sofort** ein 1:1 Image der Festplatte zu erstellen. Alle Rettungsversuche sollten dann nur noch am Image durchgeführt werden, um die originale Festplatte zu schonen.

## 1. dd (Disk Dump)
Für gesunde Festplatten. Erstellt eine bitgenaue Kopie.

> **Warnung:** `dd` überschreibt Ziele ohne Rückfrage. Vor jedem Lauf Quelle und Ziel mit `lsblk -f` prüfen und Beispielgeräte wie `/dev/sda` oder `/dev/sdb` nie ungeprüft übernehmen.

```bash
# Backup/Diagnose der Geraetezuordnung
lsblk -f
sudo smartctl -a /dev/sda

# Ein komplettes Laufwerk (/dev/sda) in eine Image-Datei sichern
sudo dd if=/dev/sda of=/pfad/zum/backup/festplatte_image.img bs=4M status=progress

# Ein Laufwerk direkt auf ein anderes klonen (Achtung: Ziel wird komplett überschrieben!)
sudo dd if=/dev/sda of=/dev/sdb bs=4M status=progress

# Verifikation
sync
sudo fdisk -l /pfad/zum/backup/festplatte_image.img
```

Rollback: Ein versehentlich ueberschriebenes Zielgeraet kann nicht per Befehl zurueckgesetzt werden. Nur ein vorheriges Image oder Backup des Zielgeraets ist ein Rueckweg.

## 2. ddrescue (Für defekte Laufwerke)
Im Gegensatz zu `dd` bricht `ddrescue` bei Lesefehlern nicht ab, sondern versucht, so viele Blöcke wie möglich zu retten und überspringt defekte Sektoren zunächst.

> **Warnung:** `ddrescue -f` darf ein Zielgerät oder eine Zieldatei überschreiben. Quelle, Ziel und Mapfile vorab prüfen und bei beschädigten Datenträgern möglichst nur einmal auf ein Image retten.

```bash
# Installation (Debian/Ubuntu)
sudo apt install gddrescue

# Schritt 1: Das Image klonen und Lesefehler protokollieren (Mapfile ist extrem wichtig!)
# Syntax: ddrescue [Optionen] Quelle Ziel Mapfile
sudo ddrescue -f -n /dev/sda /pfad/zum/backup/festplatte_image.img /pfad/zum/backup/rescue.map

# Schritt 2: Nach dem schnellen Klonen versuchen wir, die kaputten Sektoren doch noch auszulesen (mit 3 Retries)
sudo ddrescue -d -f -r3 /dev/sda /pfad/zum/backup/festplatte_image.img /pfad/zum/backup/rescue.map

# Verifikation
ls -lh /pfad/zum/backup/festplatte_image.img /pfad/zum/backup/rescue.map
ddrescuelog -t /pfad/zum/backup/rescue.map
```

Rollback: Wenn ein falsches Ziel mit `-f` ueberschrieben wurde, hilft nur dessen vorheriges Backup. Das Mapfile aufbewahren, damit Rettungslaeufe fortgesetzt statt wiederholt werden.

## 3. Images mounten und analysieren
Wenn das Image erstellt ist, muss es ins Dateisystem eingebunden werden, um darauf zuzugreifen.

```bash
# Ein Image mit einer Partition mounten
sudo mount -o loop /pfad/zum/backup/festplatte_image.img /mnt

# Bei Images ganzer Festplatten (mit mehreren Partitionen) brauchen wir kpartx
sudo apt install kpartx

# Partitionen im Image erkennen und Loop-Devices erstellen
sudo kpartx -av /pfad/zum/backup/festplatte_image.img
# Output z.B.: add map loop0p1 (Partition 1), add map loop0p2 (Partition 2)

# Dann spezifische Partition mounten
sudo mount /dev/mapper/loop0p1 /mnt

# Nach Abschluss wieder unmounten und Loops entfernen
sudo umount /mnt
sudo kpartx -d /pfad/zum/backup/festplatte_image.img
```

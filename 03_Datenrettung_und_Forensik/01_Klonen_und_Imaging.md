# 01 Klonen und Imaging

Das absolut Wichtigste bei beschädigten Datenträgern (Klackern, defekte Sektoren, unabsichtliches Löschen) ist es, **sofort** ein 1:1 Image der Festplatte zu erstellen. Alle Rettungsversuche sollten dann nur noch am Image durchgeführt werden, um die originale Festplatte zu schonen.

## 1. dd (Disk Dump)
Für gesunde Festplatten. Erstellt eine bitgenaue Kopie.

```bash
# Ein komplettes Laufwerk (/dev/sda) in eine Image-Datei sichern
sudo dd if=/dev/sda of=/pfad/zum/backup/festplatte_image.img bs=4M status=progress

# Ein Laufwerk direkt auf ein anderes klonen (Achtung: Ziel wird komplett überschrieben!)
sudo dd if=/dev/sda of=/dev/sdb bs=4M status=progress
```

## 2. ddrescue (Für defekte Laufwerke)
Im Gegensatz zu `dd` bricht `ddrescue` bei Lesefehlern nicht ab, sondern versucht, so viele Blöcke wie möglich zu retten und überspringt defekte Sektoren zunächst.

```bash
# Installation (Debian/Ubuntu)
sudo apt install gddrescue

# Schritt 1: Das Image klonen und Lesefehler protokollieren (Mapfile ist extrem wichtig!)
# Syntax: ddrescue [Optionen] Quelle Ziel Mapfile
sudo ddrescue -f -n /dev/sda /pfad/zum/backup/festplatte_image.img /pfad/zum/backup/rescue.map

# Schritt 2: Nach dem schnellen Klonen versuchen wir, die kaputten Sektoren doch noch auszulesen (mit 3 Retries)
sudo ddrescue -d -f -r3 /dev/sda /pfad/zum/backup/festplatte_image.img /pfad/zum/backup/rescue.map
```

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

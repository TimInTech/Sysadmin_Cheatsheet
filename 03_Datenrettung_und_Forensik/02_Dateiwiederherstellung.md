# 02 Dateiwiederherstellung

Wenn Dateien gelöscht oder Dateisysteme zerstört wurden (RAW-Format), sind diese Tools die letzte Rettung. Sie greifen direkt auf die Blöcke der Festplatte (oder eines Images) zu.

**Regel #1:** Niemals auf der betroffenen Festplatte installieren oder Daten darauf wiederherstellen! Wiederhergestellte Dateien immer auf ein anderes Laufwerk speichern!

## 1. TestDisk (Partitionen wiederherstellen)
TestDisk repariert verlorene Partitionstabellen und kann den Bootsektor neu aufbauen.

```bash
# Installation
sudo apt install testdisk

# TestDisk für ein Laufwerk oder Image starten
sudo testdisk /dev/sda
# ODER für ein Image:
sudo testdisk /pfad/zum/festplatte_image.img
```

**Workflow in TestDisk:**
1. `Create` (Neue Log-Datei erstellen).
2. Festplatte/Image auswählen -> `Proceed`.
3. Partitionstyp wählen (meistens `Intel` für MBR oder `EFI GPT`).
4. `Analyze` -> `Quick Search` (Sucht nach Partitionen).
5. Partitionen markieren und mit `Write` die Partitionstabelle neu schreiben.
6. Neustart.

## 2. PhotoRec (Raw-File-Recovery)
PhotoRec ist ein Begleittool von TestDisk. Es ignoriert das Dateisystem komplett und sucht anhand von Dateisignaturen (Header) nach Bildern, Videos, Dokumenten und Archiven.

```bash
# PhotoRec starten
sudo photorec /dev/sda
# ODER für ein Image:
sudo photorec /pfad/zum/festplatte_image.img
```

**Befehlsreferenz (Non-Interactive CLI):**
PhotoRec kann auch ohne Menü gesteuert werden, wenn man genau weiß, was man tut:
```bash
# Alle gefundenen Dateien von Laufwerk /dev/sda1 in den Ordner /media/backup/recovery/ extrahieren
sudo photorec /d /media/backup/recovery/ /cmd /dev/sda1 partition_none,ext2,search
```

**Workflow in PhotoRec:**
1. Laufwerk auswählen.
2. `[File Opt]` - Hier extrem wichtig: Wähle ab, was du nicht brauchst! (z.B. nur `.jpg` und `.pdf` markieren). Sonst bekommst du tausende nutzlose Systemdateien.
3. Partition auswählen (oder `No partition` um alles zu scannen).
4. Dateisystemtyp (meistens `Other` für FAT/NTFS/ext4).
5. Zielordner wählen (auf einem ANDEREN Laufwerk!) und `C` drücken.
6. Warten, bis der Prozess abgeschlossen ist. Dateien werden numerisch in Ordnern wie `recup_dir.1` abgelegt.

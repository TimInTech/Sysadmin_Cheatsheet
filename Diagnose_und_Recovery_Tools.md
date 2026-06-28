# Diagnose und Recovery Tools

Dieses Dokument bietet einen Überblick über wichtige Befehle zur Diagnose von Hardware-Problemen und zur Datenrettung für Linux und Windows.

## 1. Linux Diagnose & Recovery

### 1.1 Festplatten-Gesundheit (SMART)
S.M.A.R.T. (Self-Monitoring, Analysis and Reporting Technology) hilft, drohende Festplattenausfälle frühzeitig zu erkennen.

```bash
# Installation
sudo apt install smartmontools

# Kurzer Gesundheits-Check für Laufwerk /dev/sda
sudo smartctl -H /dev/sda

# Ausführliche SMART-Informationen anzeigen
sudo smartctl -a /dev/sda

# Einen kurzen Selbsttest starten (dauert ca. 2 Minuten)
sudo smartctl -t short /dev/sda
```

### 1.2 Arbeitsspeicher (RAM) testen
Fehlerhafter RAM verursacht oft Abstürze und unerklärliches Verhalten.

```bash
# Installation von memtester
sudo apt install memtester

# 1 GB RAM prüfen (Vorsicht: System kann währenddessen langsam reagieren)
sudo memtester 1G 1
```

### 1.3 Datenrettung (TestDisk & PhotoRec)
Wenn Partitionen verschwunden sind oder Dateien versehentlich gelöscht wurden, hilft TestDisk.

```bash
# Installation
sudo apt install testdisk

# Verlorene Partitionen wiederherstellen (interaktives Menü)
sudo testdisk

# Gelöschte Dateien (Bilder, Dokumente) von /dev/sdb1 wiederherstellen
sudo photorec /dev/sdb1
```

### 1.4 Defekte Festplatten klonen (ddrescue)
`ddrescue` liest defekte Datenträger Block für Block und überspringt Lesefehler, um so viele Daten wie möglich zu retten.

```bash
# Installation
sudo apt install gddrescue

# Laufwerk /dev/sda in eine Image-Datei klonen (mit Logdatei, damit man den Vorgang fortsetzen kann)
sudo ddrescue -d -r3 /dev/sda /pfad/zum/backup.img /pfad/zum/rescue.log
```

---

## 2. Windows Diagnose & Recovery

### 2.1 Festplatten prüfen (CHKDSK)
Das integrierte Tool zur Dateisystem-Reparatur und Fehlerprüfung.

```cmd
:: Laufwerk C: auf Dateisystemfehler prüfen und beheben
chkdsk C: /f

:: Intensiver Test inkl. Wiederherstellung fehlerhafter Sektoren (dauert sehr lange!)
chkdsk C: /f /r
```

### 2.2 Arbeitsspeicher prüfen
Windows hat eine integrierte Speicherdiagnose.

```cmd
:: Windows Speicherdiagnose beim nächsten Neustart planen
mdsched.exe
```

### 2.3 Partitionen und Festplatten mit Diskpart analysieren
Diskpart ist das Standard-CLI-Tool zur Verwaltung von Festplatten.

```cmd
:: Diskpart starten (interaktiv)
diskpart

:: Laufwerke auflisten
list disk

:: Laufwerk 0 auswählen
select disk 0

:: Partitionen anzeigen
list partition
```

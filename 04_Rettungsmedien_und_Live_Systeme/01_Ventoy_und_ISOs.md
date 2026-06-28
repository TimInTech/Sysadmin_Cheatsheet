# 01 Ventoy und ISOs

Ein Ventoy-USB-Stick ist das wichtigste Werkzeug eines jeden Administrators. Es erlaubt das Booten von hunderten verschiedenen ISO-Dateien von einem einzigen USB-Stick, ohne diese jedes Mal neu flashen zu müssen.

## 1. Ventoy installieren und pflegen

Ventoy muss nur einmal auf den USB-Stick installiert werden. Danach können ISO-Dateien einfach per Drag & Drop auf den Stick kopiert werden.

### 1.1 Ventoy-Stick erstellen (Linux)
Lade die neueste Linux-Version von der Ventoy-Website herunter und entpacke sie.
```bash
# Entpacken
tar -xzf ventoy-1.0.XX-linux.tar.gz
cd ventoy-1.0.XX

# Ventoy auf /dev/sdX installieren (WARNUNG: Löscht alle Daten auf dem Stick!)
sudo ./Ventoy2Disk.sh -i /dev/sdX
```

### 1.2 Ventoy aktualisieren
Wenn eine neue Ventoy-Version erscheint, kann das System auf dem Stick aktualisiert werden, ohne dass die ISO-Dateien gelöscht werden.
```bash
# Ventoy auf /dev/sdX aktualisieren (Behält die ISO-Daten)
sudo ./Ventoy2Disk.sh -u /dev/sdX
```

## 2. Essenzielle ISOs für den Rettungs-Stick

Folgende ISO-Dateien sollten auf keinem Admin-Stick fehlen:

1. **SystemRescue (ehemals SystemRescueCd):**
   Das Schweizer Taschenmesser. Beinhaltet GParted, ddrescue, TestDisk, Netzwerkanalysetools und Chroot-Umgebungen. Basierend auf Arch Linux.

2. **GParted Live:**
   Die beste GUI-Lösung, um Partitionen zu vergrößern, zu verkleinern oder zu verschieben, ohne das Betriebssystem booten zu müssen.

3. **Kubuntu / Ubuntu Live-ISO:**
   Eignet sich perfekt als grafische Live-Umgebung, um im Internet nach Lösungen zu suchen, während das kaputte System gemountet ist. Zudem extrem hardwarekompatibel.

4. **Windows 11 / 10 Installations-ISO:**
   Unverzichtbar für die Computerreparaturoptionen (Windows RE) und zur Neuinstallation.

5. **Hiren’s BootCD PE:**
   Eine Windows Preinstallation Environment (WinPE) vollgepackt mit Windows-Diagnosetools (Speicher, Festplatten, Passwort-Reset).

6. **Clonezilla Live:**
   Zum schnellen Erstellen von komprimierten Images kompletter Festplatten auf Netzwerkfreigaben (SMB/NFS) oder USB-Laufwerke.

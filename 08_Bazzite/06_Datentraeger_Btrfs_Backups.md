# 06 Datenträger, Btrfs und Backups

## 1. Datenträger und Dateisysteme

```bash
lsblk -e7 -o NAME,PATH,SIZE,TYPE,FSTYPE,FSVER,LABEL,UUID,MOUNTPOINTS,MODEL,SERIAL
blkid
findmnt
findmnt --verify --verbose
df -hT
df -ih
mount | column -t
```

Manuell mounten und aushängen:

```bash
sudo mkdir -p /mnt/TEST
sudo mount --read-only /dev/GERAET /mnt/TEST
findmnt /mnt/TEST
sudo umount /mnt/TEST
```

`GERAET` ist ein **PLATZHALTER**, der vorher mit `lsblk -f` eindeutig ermittelt werden muss.

- Btrfs ist für Linux-Daten, Snapshots und Bazzite-Spielebibliotheken geeignet.
- ext4 ist eine robuste Linux-Alternative ohne Btrfs-Snapshotfunktionen.
- NTFS/exFAT eignen sich für Datenaustausch; NTFS-Spielebibliotheken mit Proton werden von Bazzite nicht unterstützt.
- USB-Medien bevorzugt über den Dateimanager/udisks einhängen. Manuelle Mounts nur nach `lsblk -f` und zunächst read-only bei unbekanntem Zustand.

> **WARNUNG:** Nie ein geratenes `/dev/sdX` verwenden. Vor Mount-, Formatierungs-, Partitions- oder Repair-Befehlen Backup/Image erstellen und Modell, Seriennummer, Größe, UUID sowie Mountstatus prüfen.

## 2. SMART und NVMe

```bash
sudo smartctl --scan-open
sudo smartctl -x /dev/GERAET
sudo nvme list
sudo nvme smart-log /dev/nvme0
```

Tests:

```bash
sudo smartctl -t short /dev/GERAET
sudo smartctl -l selftest /dev/GERAET
```

> **ACHTUNG:** Bei I/O-Fehlern, steigenden Pending/Uncorrectable-Werten oder kritischen NVMe-Warnungen zuerst Daten sichern, nicht mit Schreibtests belasten.

## 3. Btrfs sichere Diagnose und Wartung

```bash
findmnt -no FSTYPE /
sudo btrfs filesystem usage /
sudo btrfs filesystem show /
sudo btrfs subvolume list /
sudo btrfs device stats /
sudo btrfs scrub status /
```

Scrub starten und Ergebnis prüfen:

```bash
sudo btrfs scrub start -Bd /
sudo btrfs scrub status /
sudo btrfs device stats /
```

> **INFO:** Scrub liest Daten/Metadaten und nutzt vorhandene Redundanz zur Korrektur. Er ersetzt kein Backup und repariert keine nicht redundanten verlorenen Daten.

Balance nur begründet und gefiltert:

```bash
sudo btrfs balance status /
sudo btrfs balance start -dusage=50 -musage=50 /
sudo btrfs balance status /
```

> **ACHTUNG:** Balance erzeugt hohe I/O-Last und braucht freien Arbeitsraum. Nicht als routinemäßige „Optimierung“ ausführen.

> **WARNUNG:** `btrfs check --repair` nicht auf einem gemounteten Dateisystem und nicht ohne aktuelles Backup/Image sowie fachkundige Analyse ausführen. Es gibt keinen zuverlässigen Undo-Pfad.

## 4. `/etc/fstab` sicher ändern

```bash
sudo cp -a /etc/fstab /etc/fstab.before-change
lsblk -f
sudoedit /etc/fstab
sudo findmnt --verify --verbose
sudo mount -a
findmnt
```

Rollback bei Fehler:

```bash
sudo cp -a /etc/fstab.before-change /etc/fstab
sudo findmnt --verify --verbose
```

UUID statt wechselnder Gerätenamen verwenden. Für Wechseldatenträger `nofail` und sinnvolle systemd-Timeouts prüfen.

## 5. Timeshift, Snapper und Atomic Rollbacks

### Timeshift-Bewertung

Timeshift ist auf Bazzite **nicht der empfohlene Standardweg**. Seine klassischen Btrfs-Annahmen (`@`-Layout und Root-Snapshot-Restore) passen nicht zur OSTree-/OCI-Deploymentverwaltung. Ein Root-Restore kann den image-basierten Zustand, `/etc` und Bootmetadaten inkonsistent machen. Daher keine Timeshift-Installations- oder Restore-Befehle in diesem Cheatsheet.

### Bazzite-eigene Snapper-Einrichtung

Aktuelle Bazzite-Images enthalten eine gepflegte Snapper-Konfiguration für `/var/home`:

```bash
ujust configure-snapshots status
ujust configure-snapshots enable
sudo snapper list
sudo btrfs subvolume list /var/home
```

> **ACHTUNG:** Snapshots liegen auf demselben Datenträger und sind kein Schutz vor SSD-Ausfall, Diebstahl, Verschlüsselungstrojanern oder versehentlicher Löschung aller Snapshots. Retention und Speicherverbrauch kontrollieren.

Deaktivieren ohne automatisches Löschen:

```bash
ujust configure-snapshots disable
```

> **WARNUNG:** `ujust configure-snapshots wipe` entfernt die Konfiguration und automatische Snapshots. Nur nach externem Backup und Prüfung der benötigten Snapshots ausführen.

## 6. Praktische 3-2-1-Backupstrategie

| Ebene | Was sichern | Methode |
|---|---|---|
| System | Imagequelle, Layerliste, Deploymentstatus | OSTree-Rollback + exportierte Statusdatei |
| Konfiguration | `/etc`, Dotfiles, Quadlets, Compose-Dateien | Restic/Borg auf externes Ziel |
| Benutzerdaten | `/var/home/USER` | Pika Backup, Déjà Dup, Restic oder Borg |
| Flatpak | `~/.var/app/APP_ID` für relevante Apps | In Dateibackup einschließen |
| Container | deklarative Dateien, Secrets separat, Volumes | App-konsistenter Dump + Volume-Backup |
| Offsite | Verschlüsselte Kopie | Zweites externes Medium oder vertrauenswürdiger Speicher |

> **INFO:** 3-2-1 bedeutet drei Kopien, zwei unterschiedliche Medientypen/Fehlerdomänen und eine Kopie außerhalb des Gerätestandorts.

### Konfigurationsinventar exportieren

```bash
mkdir -p ~/backup-inventory
rpm-ostree status -v > ~/backup-inventory/rpm-ostree-status.txt
flatpak list --app --columns=application,origin > ~/backup-inventory/flatpaks.txt
brew bundle dump --file=~/backup-inventory/Brewfile --force 2>/dev/null || true
distrobox list > ~/backup-inventory/distrobox-list.txt
podman ps -a --format '{{.Names}} {{.Image}}' > ~/backup-inventory/podman-containers.txt
```

### Restic-Beispiel mit Dry-Run und Verifikation

```bash
restic -r /run/media/$USER/BACKUP/restic snapshots
restic -r /run/media/$USER/BACKUP/restic backup --dry-run "$HOME" /etc
restic -r /run/media/$USER/BACKUP/restic backup "$HOME" /etc
restic -r /run/media/$USER/BACKUP/restic check
```

`BACKUP` ist ein **PLATZHALTER**. Repository-Passwort sicher über den dokumentierten Restic-Mechanismus bereitstellen, nicht in Shell-History oder Git schreiben.

### Restore regelmäßig testen

```bash
mkdir -p ~/restore-test
restic -r /run/media/$USER/BACKUP/restic restore latest --target ~/restore-test --include /home/$USER/TESTDATEI
cmp "$HOME/TESTDATEI" "$HOME/restore-test/home/$USER/TESTDATEI"
```

> **TIPP:** Pika Backup oder Déjà Dup sind für Desktopnutzer geeignete Flatpak-Oberflächen. Borg/Restic eignen sich für reproduzierbare CLI-Backups. Das Ziel muss extern und regelmäßig getrennt oder schreibgeschützt sein.


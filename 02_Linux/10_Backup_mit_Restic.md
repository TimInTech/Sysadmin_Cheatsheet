# 10 Backup mit restic (Linux)

`restic` erstellt deduplizierte, verschluesselte Backups auf lokale Datentraeger, SFTP, S3-kompatible Speicher und weitere Backends. Entscheidend ist nicht nur das Backup, sondern regelmaessige Wiederherstellungspruefung.

> **Hinweis:** 3-2-1-Regel – mindestens drei Kopien der Daten, auf zwei verschiedenen Medientypen, eine Kopie davon extern (offsite). Ein Backup gilt erst nach erfolgreichem Restore-Test als verifiziert.

Quellen:

- restic Dokumentation: <https://restic.readthedocs.io/>
- restic Projektseite: <https://restic.net/>

## 0. Version prüfen

```bash
restic version
```

## 1. Repository initialisieren

> **Warnung:** Das restic-Passwort schuetzt den Zugriff auf das Backup. Ohne Passwort sind Backups nicht wiederherstellbar; mit offengelegtem Passwort koennen Dritte die Backups lesen. Passwort nicht in Shell-Historie, Unit-Dateien oder Skripte schreiben.

```bash
# Passwortdatei mit restriktiven Rechten anlegen
sudo install -m 600 /dev/null /root/.restic-password
sudo editor /root/.restic-password

# Repository auf externer Platte initialisieren
sudo RESTIC_PASSWORD_FILE=/root/.restic-password \
  restic -r /mnt/backup/restic-repo init
```

Verifikation:

```bash
sudo RESTIC_PASSWORD_FILE=/root/.restic-password \
  restic -r /mnt/backup/restic-repo snapshots
```

## 2. Backup ausfuehren

```bash
sudo RESTIC_PASSWORD_FILE=/root/.restic-password \
  restic -r /mnt/backup/restic-repo backup /etc /home \
  --exclude /home/*/.cache \
  --exclude /home/*/Downloads
```

Pruefpunkte:

- Ist das Zielmedium gemountet und beschreibbar?
- Sind Datenbanken, VM-Images oder Container-Volumes konsistent gesichert?
- Sind grosse Cache- und Build-Verzeichnisse bewusst ausgeschlossen?

## 3. Integritaet pruefen

```bash
# Struktur und Metadaten pruefen
sudo RESTIC_PASSWORD_FILE=/root/.restic-password \
  restic -r /mnt/backup/restic-repo check

# Stichprobenartig Daten lesen
sudo RESTIC_PASSWORD_FILE=/root/.restic-password \
  restic -r /mnt/backup/restic-repo check --read-data-subset=5%
```

## 4. Restore testen

```bash
# Snapshots anzeigen
sudo RESTIC_PASSWORD_FILE=/root/.restic-password \
  restic -r /mnt/backup/restic-repo snapshots

# Einzelnes Verzeichnis in Testpfad wiederherstellen
sudo mkdir -p /tmp/restic-restore-test
sudo RESTIC_PASSWORD_FILE=/root/.restic-password \
  restic -r /mnt/backup/restic-repo restore latest \
  --target /tmp/restic-restore-test \
  --include /etc/ssh
```

Verifikation:

```bash
sudo find /tmp/restic-restore-test -maxdepth 3 -type f | head
sudo diff -qr /etc/ssh /tmp/restic-restore-test/etc/ssh
```

### 4.1 Restore-Verifikation mit Prüfsummen

```bash
# Prüfsumme des Backup-Archivs erstellen
sha256sum /pfad/zum/backup.tar.gz | tee /pfad/zum/backup.tar.gz.sha256

# Prüfsumme später verifizieren
sha256sum -c /pfad/zum/backup.tar.gz.sha256

# Backup-Inventar anzeigen
find /pfad/zum/backup/ -maxdepth 2 -type f -printf '%TY-%Tm-%Td %TH:%TM %s %p\n' | sort | tail -n 80
```

Rollback:

> **Warnung:** `rm -rf` entfernt den Restore-Testpfad ohne Papierkorb. Nur den eindeutig angelegten Testpfad loeschen.

```bash
sudo rm -rf /tmp/restic-restore-test
```

## 5. Aufbewahrung und Prune

> **Warnung:** `forget --prune` entfernt nicht mehr benoetigte Snapshots und loescht Datenbloecke dauerhaft aus dem Repository. Vorher `snapshots`, `check` und die Retention-Regeln trocken pruefen.

```bash
# Trockenlauf: zeigt, was geloescht wuerde
sudo RESTIC_PASSWORD_FILE=/root/.restic-password \
  restic -r /mnt/backup/restic-repo forget \
  --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --dry-run

# Erst nach Pruefung ausfuehren
sudo RESTIC_PASSWORD_FILE=/root/.restic-password \
  restic -r /mnt/backup/restic-repo forget \
  --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
```

Verifikation:

```bash
sudo RESTIC_PASSWORD_FILE=/root/.restic-password \
  restic -r /mnt/backup/restic-repo snapshots

sudo RESTIC_PASSWORD_FILE=/root/.restic-password \
  restic -r /mnt/backup/restic-repo check
```

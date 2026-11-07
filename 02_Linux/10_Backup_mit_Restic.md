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
  --exclude '/home/*/.cache' \
  --exclude '/home/*/Downloads'
```

> **Wichtig:** Die Muster in `--exclude` gehören in Anführungszeichen. Ohne sie ersetzt die Shell `/home/*/.cache` durch alle passenden Ordner. Ab dem zweiten Benutzer landen die Pfade dann als Backup-Ziel statt als Ausnahme im Befehl, und deren Caches werden **mitgesichert**. Getestet mit restic 0.19.1.

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

## 6. Täglich automatisch per systemd-Timer

Der Timer startet das Backup jeden Tag um 03:00. War der Rechner zu der Zeit aus, holt `Persistent=true` den Lauf beim nächsten Start nach. Das Passwort bleibt in der Datei aus Abschnitt 1 und steht nicht in der Unit. Grundlagen zu Timern: [systemd Timer und Journal](09_Systemd_Timer_und_Journal.md).

> **Warnung:** Die Zeile `ExecStartPost` löscht nach jedem erfolgreichen Backup alte Snapshots dauerhaft (`forget --prune`). Die Aufbewahrungsregeln vorher mit dem Trockenlauf aus Abschnitt 5 prüfen. Wer das nicht automatisch will, lässt die Zeile weg.

```bash
# Pfad des restic-Programms ermitteln; muss zu ExecStart passen
command -v restic
```

`/etc/systemd/system/restic-backup.service`:

```ini
[Unit]
Description=restic Backup
# Haengt /mnt/backup vorher ein und bricht ab, wenn das nicht klappt
RequiresMountsFor=/mnt/backup

[Service]
Type=oneshot
Environment=RESTIC_REPOSITORY=/mnt/backup/restic-repo
Environment=RESTIC_PASSWORD_FILE=/root/.restic-password
ExecStart=/usr/bin/restic backup /etc /home --exclude '/home/*/.cache' --exclude '/home/*/Downloads' --tag taeglich
ExecStartPost=/usr/bin/restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
# Andere Programme so wenig wie möglich ausbremsen
Nice=10
IOSchedulingClass=idle
```

`/etc/systemd/system/restic-backup.timer`:

```ini
[Unit]
Description=restic Backup taeglich um 03:00

[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true
RandomizedDelaySec=15min

[Install]
WantedBy=timers.target
```

```bash
# Unit-Dateien prüfen und Timer aktivieren
sudo systemd-analyze verify /etc/systemd/system/restic-backup.service /etc/systemd/system/restic-backup.timer
sudo systemctl daemon-reload
sudo systemctl enable --now restic-backup.timer

# Einmal sofort ausführen und Ergebnis ansehen
sudo systemctl start restic-backup.service
journalctl -u restic-backup.service -n 30 --no-pager
systemctl list-timers restic-backup.timer
```

In der Unit-Datei sind die Anführungszeichen um die Muster unproblematisch: systemd gibt sie als ein Argument an restic weiter und erweitert keine `*`.

`RequiresMountsFor` schützt nur, wenn `/mnt/backup` ein eigener Eintrag in `/etc/fstab` ist. Ist es nur ein Ordner auf der Systemplatte, schreibt restic das Backup dorthin und füllt die Systemplatte.

**Rollback:**

```bash
sudo systemctl disable --now restic-backup.timer
sudo rm /etc/systemd/system/restic-backup.service /etc/systemd/system/restic-backup.timer
sudo systemctl daemon-reload
```

Getestet auf: Ubuntu 26.04 mit systemd 259 (beide Unit-Dateien mit `systemd-analyze verify` geprüft). Den Lauf selbst habe ich nicht getestet, weil hier kein restic installiert ist. Quelle: [systemd.exec(5)](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html), [systemd.timer(5)](https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html).

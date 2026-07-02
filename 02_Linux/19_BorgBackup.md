# 19 BorgBackup (Linux)

Borg: deduplizierende Backups mit Verschluesselung, Pruefung und Aufraeumung.

> **Warnung:** Der Repository-Key (`repokey`) ist im Backup-Header gespeichert. Ohne Passphrase sind die Daten unlesbar. Passphrase sicher verwahren – kein Backup-Key, keine Wiederherstellung.

Quellen:

- Borg Documentation: <https://borgbackup.readthedocs.io/>

## 1. Repository initialisieren

```bash
REPO=/pfad/zum/repository
borg init --encryption=repokey "$REPO"
```

## 2. Backup erstellen

```bash
REPO=/pfad/zum/repository
SRC=/pfad/zum/quelldaten
ARCHIVE="$(hostname)-$(date +%Y%m%d-%H%M%S)"
borg create --stats --progress "$REPO::$ARCHIVE" "$SRC"
```

## 3. Repository prüfen und Archive auflisten

```bash
borg list "$REPO"
borg check "$REPO"
```

## 4. Daten extrahieren

```bash
borg extract "$REPO"::ARCHIVNAME --destination /zielpfad
```

## 5. Alte Archive entfernen (Prune)

```bash
borg prune --keep-daily 7 --keep-weekly 4 --keep-monthly 6 "$REPO"
```

# 18 rsync (Linux)

rsync mit Dry-Run, Backup und Warnung vor `--delete`.

> **Warnung:** `--delete` loescht Dateien im Ziel, die in der Quelle nicht existieren. Vorher immer Dry-Run ausfuehren.

Quellen:

- rsync Manual: <https://rsync.samba.org/documentation.html>

## 1. Quelle und Ziel prüfen

```bash
SRC=/pfad/zum/quellverzeichnis
DST=/pfad/zum/zielverzeichnis
test -e "$SRC" && echo Quellpfad OK
test -d "$DST" && echo Zielverzeichnis OK
du -sh "$SRC"
df -hT "$DST"
```

## 2. Dry-Run

```bash
rsync -aHAX --numeric-ids --info=progress2 --dry-run "$SRC" "$DST"
```

## 3. Backup ausführen

```bash
rsync -aHAX --numeric-ids --info=progress2 "$SRC" "$DST"
```

Verifikation:

```bash
rsync -aHAX --numeric-ids --info=progress2 --dry-run "$SRC" "$DST"
```

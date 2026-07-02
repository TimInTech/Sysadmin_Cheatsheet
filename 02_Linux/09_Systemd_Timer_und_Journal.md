# 09 systemd Timer und Journal (Linux)

`systemd`-Timer ersetzen viele Cron-Jobs und lassen sich mit `systemctl` und `journalctl` sauber pruefen. Wichtig ist die Trennung zwischen `.service` und `.timer`: Der Timer startet den Service.

Quellen:

- systemd.timer Manual: <https://man7.org/linux/man-pages/man5/systemd.timer.5.html>
- systemd Journal Manual: <https://www.freedesktop.org/software/systemd/man/latest/journalctl.html>

## 1. Vorhandene Timer und naechste Laeufe pruefen

```bash
# Alle aktiven Timer anzeigen
systemctl list-timers

# Auch inaktive Timer anzeigen
systemctl list-timers --all

# Status eines konkreten Timers pruefen
systemctl status backup.timer
```

## 2. Service-Datei fuer einen Job anlegen

> **Warnung:** Timer starten Befehle automatisch und ggf. als root. Skripte vorher manuell mit Testdaten ausfuehren, Pfade absolut setzen und keine Secrets in Unit-Dateien schreiben.

`/etc/systemd/system/backup.service`:

```ini
[Unit]
Description=Lokales Backup ausfuehren

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/backup-job.sh
```

Verifikation:

```bash
# Syntax und Aufloesung der Unit pruefen
systemd-analyze verify /etc/systemd/system/backup.service

# Job einmal manuell starten
sudo systemctl start backup.service

# Ergebnis anzeigen
systemctl status backup.service
journalctl -u backup.service -n 100 --no-pager
```

## 3. Timer-Datei anlegen

`/etc/systemd/system/backup.timer`:

```ini
[Unit]
Description=Backup taeglich starten

[Timer]
OnCalendar=*-*-* 03:30:00
Persistent=true
RandomizedDelaySec=15m
Unit=backup.service

[Install]
WantedBy=timers.target
```

Aktivieren:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now backup.timer
systemctl list-timers backup.timer
```

Rollback:

```bash
sudo systemctl disable --now backup.timer
sudo rm /etc/systemd/system/backup.timer /etc/systemd/system/backup.service
sudo systemctl daemon-reload
```

## 4. Logs gezielt lesen

```bash
# Nur aktuelle Boot-Sitzung
journalctl -u backup.service -b --no-pager

# Zeitraum eingrenzen
journalctl -u backup.service --since "today 03:00" --until "today 04:00"

# Live verfolgen
journalctl -u backup.service -f
```

## 5. Journal-Groesse begrenzen

> **Warnung:** `journalctl --vacuum-*` loescht alte Logs. Vorher relevante Fehler exportieren, wenn sie fuer Audit, Incident Response oder Ursachenanalyse benoetigt werden.

```bash
# Aktuelle Journal-Nutzung anzeigen
journalctl --disk-usage

# Alte Logs bis auf 1G reduzieren
sudo journalctl --vacuum-size=1G

# Verifikation
journalctl --disk-usage
```

Rollback:

- Geloeschte Journal-Eintraege lassen sich nicht wiederherstellen.
- Falls Audit-Aufbewahrung noetig ist, vorher exportieren:

```bash
journalctl -u backup.service --since "2026-07-01" > backup-service-journal.txt
```

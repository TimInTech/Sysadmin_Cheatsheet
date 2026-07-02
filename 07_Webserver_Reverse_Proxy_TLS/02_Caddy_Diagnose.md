# 02 Caddy Diagnose

Caddy Diagnose.

## Sicherheitsrahmen

> HINWEIS: Reine Diagnose. Keine Änderung am System.

> WARNUNG: Änderung an Dienst, Netzwerk, Firewall, Storage, Backup, Benutzerrechten oder Konfiguration. Vorher Backup/Snapshot/Rollback prüfen.

> KRITISCH: Potenziell destruktiv. Nur mit eindeutig geprüftem Ziel, Backup und bewusster Bestätigung ausführen.

## Grundregel

1. Erst Zustand prüfen.
2. Ziel eindeutig ermitteln.
3. Änderung nur mit Backup/Snapshot/Rollback-Pfad ausführen.
4. Ergebnis verifizieren.
5. Keine Secrets, Tokens oder Klartextpasswörter dokumentieren.

## Status und Validate

```bash
caddy version
systemctl status caddy --no-pager
caddy validate --config /etc/caddy/Caddyfile
```

## Logs

```bash
journalctl -u caddy -b --no-pager | tail -n 180
```

## Verifikation

```bash
echo 'Dokumentationsprüfung: Befehle vor produktiver Nutzung im Zielsystem prüfen.'
```

## Rollback

Wenn eine Änderung ausgeführt wurde: Konfiguration aus Backup/VCS/Snapshot zurückspielen, Dienststatus prüfen und Logs erneut lesen.

## Quellen

- <https://nginx.org/en/docs/>
- <https://caddyserver.com/docs/>

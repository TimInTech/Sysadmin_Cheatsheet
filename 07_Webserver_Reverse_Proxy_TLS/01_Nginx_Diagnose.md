# 01 Nginx Diagnose

Nginx Diagnose.

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

## Status und Syntax

```bash
nginx -v
sudo nginx -t
systemctl status nginx --no-pager
```

## Logs

```bash
sudo journalctl -u nginx -b --no-pager | tail -n 160
sudo tail -n 160 /var/log/nginx/error.log 2>/dev/null || true
```

## Konfiguration

```bash
sudo nginx -T 2>/dev/null | sed -n '1,220p'
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

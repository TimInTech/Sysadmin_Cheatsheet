# 04 Reverse Proxy Fehlerbilder

502/503/504 und Backend-Diagnose.

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

## Backend testen

```bash
read -r -p 'Backend-Host: ' HOST
read -r -p 'Backend-Port: ' PORT
nc -vz "$HOST" "$PORT"
curl -I "http://$HOST:$PORT" 2>/dev/null || true
```

## Proxy-Logs

```bash
sudo journalctl -b --no-pager | grep -Ei 'nginx|caddy|502|503|504|upstream|proxy' | tail -n 180
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

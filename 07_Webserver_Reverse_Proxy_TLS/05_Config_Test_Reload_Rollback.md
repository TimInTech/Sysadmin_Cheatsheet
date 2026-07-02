# 05 Config Test Reload Rollback

Config-Test, Reload und Rollback.

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

## Nginx Backup und Test

```bash
sudo mkdir -p /root/webserver-config-backups
sudo tar czf /root/webserver-config-backups/nginx-$(date +%Y%m%d-%H%M%S).tar.gz /etc/nginx
sudo nginx -t
```

## Caddy Backup und Test

```bash
sudo mkdir -p /root/webserver-config-backups
sudo tar czf /root/webserver-config-backups/caddy-$(date +%Y%m%d-%H%M%S).tar.gz /etc/caddy
caddy validate --config /etc/caddy/Caddyfile
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

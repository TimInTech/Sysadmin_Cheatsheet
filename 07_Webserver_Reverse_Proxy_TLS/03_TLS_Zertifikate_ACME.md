# 03 TLS Zertifikate ACME

TLS-Zertifikate und ACME.

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

## Zertifikat prüfen

```bash
read -r -p 'Domain eingeben: ' DOMAIN
echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null | openssl x509 -noout -subject -issuer -dates
```

## HTTP Header

```bash
read -r -p 'URL eingeben: ' URL
curl -I "$URL"
```

## Certbot

```bash
certbot certificates 2>/dev/null || true
systemctl list-timers | grep -i certbot || true
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

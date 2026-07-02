# 07 Webserver Reverse Proxy TLS

Rubrik: Webserver Reverse Proxy TLS.

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

## Dateien

- [01 Nginx Diagnose](01_Nginx_Diagnose.md) — Nginx Diagnose.
- [02 Caddy Diagnose](02_Caddy_Diagnose.md) — Caddy Diagnose.
- [03 TLS Zertifikate ACME](03_TLS_Zertifikate_ACME.md) — TLS-Zertifikate und ACME.
- [04 Reverse Proxy Fehlerbilder](04_Reverse_Proxy_Fehlerbilder.md) — 502/503/504 und Backend-Diagnose.
- [05 Config Test Reload Rollback](05_Config_Test_Reload_Rollback.md) — Config-Test, Reload und Rollback.

## Quellen

- <https://nginx.org/en/docs/>
- <https://caddyserver.com/docs/>

# 04 Branch Protection Rulesets

Branch Protection und Rulesets.

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

## GitHub CLI

```bash
gh repo view --json nameWithOwner,defaultBranchRef,visibility
gh ruleset list
```

## Verifikation

```bash
echo 'Dokumentationsprüfung: Befehle vor produktiver Nutzung im Zielsystem prüfen.'
```

## Rollback

Wenn eine Änderung ausgeführt wurde: Konfiguration aus Backup/VCS/Snapshot zurückspielen, Dienststatus prüfen und Logs erneut lesen.

## Quellen

- <https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning>

# 06 Git-Repo-Hygiene

Rubrik: Git-Repo-Hygiene.

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

- [01 Repo Checkliste](01_Repo_Checkliste.md) — Git-Status und Repo-Inventar.
- [02 Secret Hygiene](02_Secret_Hygiene.md) — Secret-Hygiene.
- [03 Markdownlint und Linkcheck](03_Markdownlint_und_Linkcheck.md) — Markdownlint und Linkcheck.
- [04 Branch Protection Rulesets](04_Branch_Protection_Rulesets.md) — Branch Protection und Rulesets.
- [05 PR und Release Checkliste](05_PR_und_Release_Checkliste.md) — PR- und Release-Checkliste.

## Quellen

- <https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning>

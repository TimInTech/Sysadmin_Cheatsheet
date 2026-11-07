# Mitmachen

Danke, dass du das Sysadmin-Cheatsheet verbessern möchtest. Fehlerhinweise sind genauso willkommen wie neue Befehle. Am einfachsten startest du mit einem [Issue](https://github.com/TimInTech/Sysadmin_Cheatsheet/issues/new/choose).

## 1. Grundsätze

1. **Einfache Sprache zuerst**, die Technik darunter. Jede Seite beginnt mit ein, zwei Sätzen, wofür sie gut ist.
2. **Nichts erfinden.** Jeder Befehl ist gegen die offizielle Dokumentation oder die Hilfe des Werkzeugs (`--help`, `man`, `/?`) geprüft. Die Quelle steht auf der Seite.
3. **Ehrlich kennzeichnen.** Unter getesteten Befehlen steht `Getestet auf: …` mit System und Version, zum Beispiel `Getestet auf: Ubuntu 26.04`. Ungetestetes ist als **nicht getestet** markiert.
4. **Gefährliche Befehle** bekommen davor eine Warnung, die sagt, was verloren gehen kann, und möglichst einen Probelauf und einen Rollback.
5. **Keine Dubletten.** Erst suchen, ob es das Thema schon gibt, und dann die vorhandene Seite ergänzen oder verlinken.
6. **Keine Secrets und keine privaten Daten:** keine Passwörter, Tokens, echten Benutzernamen, privaten IP-Adressen oder Hostnamen aus dem eigenen Netz. Platzhalter heißen `PLATZHALTER` oder sind sprechend benannt, etwa `benutzer@server_ip`.

## 2. Seitenaufbau

```markdown
# NN Titel (System)

Ein, zwei Sätze: wofür die Seite gut ist.

Quellen:

- Offizielle Doku: <https://…>

## 1. Erster Schritt

> **Warnung:** Was passiert, wenn es schiefgeht.

    Befehle mit kurzem Kommentar

Getestet auf: Ubuntu 26.04.
```

Code-Kommentare in Skripten sind auf Englisch, der Text auf Deutsch. Neue Seiten bekommen einen Eintrag in der `README.md` ihres Ordners.

## 3. Pull Request

1. Einen eigenen Branch pro Thema anlegen, nie direkt auf `main` arbeiten.
2. Vor dem Commit lokal prüfen:

   ```bash
   git diff --check
   npx -y markdownlint-cli2 "**/*.md"
   ```

3. Links prüfen, zum Beispiel mit `curl -sIL -o /dev/null -w '%{http_code}\n' URL`.
4. Für Commits die GitHub-No-Reply-Adresse verwenden, damit die private E-Mail nicht öffentlich wird ([GitHub-Hilfe](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/setting-your-commit-email-address)).
5. Im Pull Request kurz beschreiben, was sich ändert und worauf es getestet wurde.

Gemergt wird nach Durchsicht durch den Maintainer. Die Prüfungen in GitHub Actions (markdownlint, Toolkit-Tests) müssen grün sein.

## 4. Was nicht hinein soll

- Ungeprüfte oder zerstörerische Einzeiler ohne Erklärung und Warnung
- Lange Theorie ohne praktischen Nutzen
- Werbe- oder Affiliate-Links
- Kopierter Code oder Text aus Projekten mit unverträglicher Lizenz. Dieses Repository steht unter der [MIT-Lizenz](LICENSE); Beiträge stehen unter derselben Lizenz.

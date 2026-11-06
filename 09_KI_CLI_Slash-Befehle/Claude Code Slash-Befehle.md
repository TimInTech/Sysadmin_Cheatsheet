# Claude Code – Slash-Befehle

Claude Code 2.1.308, Stand 2026-10-22. Quelle: <https://code.claude.com/docs/en/commands>

> [!NOTE] Stand
> Aus der offiziellen Befehlsreferenz vom **2026-10-22**, Version 2.1.308. `/` zeigt, was deine Installation, dein Plan und deine Plugins wirklich anbieten; einige Befehle sind bis zur vollständigen Eingabe ausgeblendet. **[Skill]** = mitgelieferter Skill (ein Prompt, kein fest eingebauter Code).

## Sitzung und Verlauf

| Befehl | Wirkung |
| --- | --- |
| `/clear [name]` | neue Unterhaltung mit leerem Kontext |
| `/compact [Hinweis]` | Verlauf zusammenfassen |
| `/autocompact [auto\|Tokens]` | Schwelle für automatisches Komprimieren |
| `/resume [Sitzung]` | frühere Unterhaltung öffnen |
| `/branch [name]` | Unterhaltung abzweigen |
| `/fork [Prompt]` | Kopie als Hintergrundsitzung, hier weiterarbeiten |
| `/rewind` (`/checkpoint`, `/undo`) | Code und/oder Unterhaltung zurücksetzen |
| `/rename [name]` · `/recap` · `/export [Datei]` | umbenennen · Einzeiler-Zusammenfassung · als Text exportieren |
| `/copy [N]` | letzte (N-te) Antwort kopieren |
| `/cd <Pfad>` · `/add-dir <Pfad>` | Arbeitsverzeichnis wechseln · weiteres freigeben |
| `/btw [Frage]` | Nebenfrage ohne Verlauf |
| `/exit` (`/quit`) | beenden |

## Arbeiten und Prüfen

| Befehl | Wirkung |
| --- | --- |
| `/plan [Beschreibung]` | Plan-Modus |
| `/goal [Bedingung\|clear]` | über mehrere Züge arbeiten, bis die Bedingung erfüllt ist |
| `/diff` | Änderungen im Arbeitsbaum ansehen |
| `/code-review [Stufe] [--fix] [--comment] [pr#\|branch\|pfad]` (`/review`) | [Skill] Diff oder PR prüfen; Stufen `low` bis `max`, `ultra` = Cloud-Review |
| `/security-review` | Branch-Änderungen auf Sicherheitslücken prüfen |
| `/ultrareview [PR\|Branch]` | tiefes Multi-Agent-Review in der Cloud (nur vom Nutzer auslösbar, kostenpflichtig) |
| `/simplify [Ziel]` | [Skill] Änderungen auf Wiederverwendung/Einfachheit prüfen und anwenden |
| `/batch <Anweisung>` | [Skill] große Änderung in 5–30 parallele Einheiten zerlegen |
| `/loop [Intervall] [Prompt]` | [Skill] Prompt wiederholt ausführen |
| `/schedule [Beschreibung]` | [Skill] Cloud-Routinen anlegen/ändern/starten |
| `/run` · `/verify` · `/run-skill-generator` | [Skill] App starten und Änderung real prüfen |
| `/debug [Beschreibung]` | [Skill] Debug-Log der Sitzung auswerten |
| `/subtask <Aufgabe>` | geforkter Subagent im Hintergrund |
| `/tasks` (`/bashes`) · `/background [Prompt]` · `/stop` | Hintergrundarbeit anzeigen · Sitzung lösen · beenden |
| `/deep-research <Frage>` · `/workflows` | Workflow: Recherche mit Quellen · Fortschritt ansehen |
| `/autofix-pr [Prompt]` | Cloud-Sitzung, die PR-CI-Fehler und Kommentare bearbeitet |
| `/claude-api [Thema]` | [Skill] API-Referenz, Migration, Prompt-Audit |

## Modell, Kontext, Rechte

| Befehl | Wirkung |
| --- | --- |
| `/model [Modell]` | Modell wechseln (als Standard gespeichert) |
| `/effort [low…max\|auto\|status]` | Reasoning-Aufwand |
| `/fast [on\|off]` | Fast-Modus |
| `/advisor [Modell\|off]` | zweites Modell als Berater |
| `/context [all]` | Kontextauslastung als Raster |
| `/usage` (`/cost`, `/stats`) · `/usage-credits` | Kosten, Limits, Aktivität · Guthaben |
| `/permissions` | Allow-/Ask-/Deny-Regeln |
| `/sandbox` | Sandbox-Modus |
| `/hooks` | Hook-Konfiguration ansehen |
| `/auto-mode-setup` | Auto-Mode-Umgebung entwerfen |
| `/fewer-permission-prompts` | [Skill] Allowlist aus Transkripten ableiten |
| `/update-config [Wunsch]` | [Skill] settings.json ändern |
| `/config [key=value]` | Einstellungen |
| `/status` | Version, Modell, Konto, Verbindung |
| `/doctor` | [Skill] Setup-Check mit Reparaturvorschlägen |
| `/memory` | `CLAUDE.md` und Auto-Memory bearbeiten |
| `/init` | `CLAUDE.md` anlegen |
| `/import [codex\|gemini\|cursor] [--dry-run]` | Konfiguration aus anderen Agenten übernehmen |

## Erweitern und Integrationen

`/mcp [reconnect\|enable\|disable]` · `/plugin [list\|install\|enable\|disable]` · `/reload-plugins` · `/reload-skills` · `/skills` · `/skill-doctor` · `/agents` (Hinweis auf Subagents) · `/list-agents` · `/plugin-authoring` · `/ide` · `/chrome` · `/claude-in-chrome [Aufgabe]` · `/install-github-app` · `/install-slack-app` · `/web-setup` · `/remote-control` · `/remote-env` · `/desktop` (`/app`) · `/teleport` (`/tp`) · `/mobile` · `/artifacts` · `/design`, `/design-sync`, `/design-login` · `/slides` · `/dataviz` · `/artifact-capabilities` · `/artifact-diagramming` · `/workflow-authoring`.

## Darstellung, Konto, Sonstiges

`/theme` · `/color` · `/statusline` · `/output-style` · `/focus` · `/tui [default\|fullscreen]` · `/scroll-speed` · `/keybindings` · `/terminal-setup` · `/voice` · `/login` · `/logout` · `/upgrade` · `/privacy-settings` · `/rate-limit-options` · `/help` · `/release-notes` · `/insights` · `/team-onboarding` · `/feedback` (`/bug`) · `/heapdump` · `/powerup` · `/radio` · `/stickers` · `/passes` · `/setup-bedrock` · `/setup-vertex`.

## Entfernt

`/vim` (seit 2.1.92; jetzt `/config` → Editor mode), `/pr-comments` (seit 2.1.91), `/ultraplan` (stattdessen Plan-Modus).

## Eingabe-Präfixe und Tasten

`@` Datei · `!` Shell · `/` Menü · `Shift+Tab` Modus wechseln · `Esc Esc` zurückspulen · `Ctrl+R` Verlauf suchen · `Ctrl+G` externer Editor · `Ctrl+C` abbrechen. Eigene Befehle sind Skills unter `.claude/skills/` bzw. `~/.claude/skills/`.

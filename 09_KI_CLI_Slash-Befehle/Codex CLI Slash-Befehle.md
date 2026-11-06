# Codex CLI – Slash-Befehle

Codex CLI 0.163.0, Stand 2026-10-22. Quellen: OpenAI-Codex-Dokumentation (CLI-Unterbefehle) und das Slash-Menü der CLI (`/` im TUI).

> [!NOTE] Stand
> Geprüft am **2026-10-22** in **Codex CLI 0.163.0**: `/` im TUI geöffnet und das ganze Menü durchgeblättert. Das Menü hängt von Version, Anmeldung und Feature-Flags ab; `/` zeigt immer, was deine Installation wirklich kennt. Die Slash-Befehle der **ChatGPT-Desktop-App** sind eine andere Liste (z. B. `/cloud`, `/local`, `/project`, `/pin`) und gelten nicht für die CLI.

## Sitzung und Verlauf

| Befehl | Wirkung |
|---|---|
| `/new` | neuen Chat in laufender Sitzung beginnen |
| `/clear` | Terminal leeren und neuen Chat starten |
| `/resume` | gespeicherten Chat fortsetzen |
| `/fork` | aktuellen Chat abzweigen |
| `/side` | Nebenunterhaltung in kurzlebigem Fork |
| `/worktree` | Unterhaltung in neuem Git-Worktree starten oder fortsetzen |
| `/compact` | Verlauf zusammenfassen, Kontext freigeben |
| `/recap` | aktuelle Unterhaltung jetzt zusammenfassen |
| `/rename` | Thread umbenennen |
| `/title` | Elemente des Terminaltitels festlegen |
| `/archive` / `/delete` | Sitzung archivieren / endgültig löschen |
| `/export` | Unterhaltung als Markdown ausgeben |
| `/copy` | letzte Antwort oder Teile davon kopieren |
| `/exit` | Codex beenden |

## Arbeiten und Prüfen

| Befehl | Wirkung |
|---|---|
| `/init` | `AGENTS.md` mit Projektanweisungen anlegen |
| `/plan` | Plan-Modus |
| `/goal` | Ziel für lange Aufgabe setzen oder anzeigen |
| `/review` | aktuelle Änderungen prüfen |
| `/diff` | Git-Diff inklusive untracked Dateien |
| `/mention` | Datei an die Unterhaltung hängen |
| `/ide` | Auswahl, offene Dateien und Kontext aus der IDE |
| `/skills` | Skills nutzen |
| `/agents` | Agent-Kommandozentrale |
| `/subagents` | zwischen Subagents der Sitzung wechseln |
| `/ps` / `/stop` | Hintergrund-Terminals auflisten / alle beenden |
| `/cd` / `/pwd` | Arbeitsverzeichnis wechseln / anzeigen |

## Modell, Rechte, Einstellungen

| Befehl | Wirkung |
|---|---|
| `/model` | Modell und Reasoning-Aufwand |
| `/fast` | Fast-Tier (1,5× Tempo) |
| `/permissions` | Freigabe- bzw. Rechteprofil |
| `/approve` | eine abgelehnte Auto-Review-Aktion einmal erneut zulassen |
| `/hooks` | Lifecycle-Hooks ansehen und verwalten |
| `/mcp` | MCP-Tools; `/mcp verbose`, `/mcp login <name>` |
| `/plugins` | Plugins durchsuchen |
| `/memories` | Gedächtnis-Nutzung und -Erzeugung festlegen |
| `/import` | Setup, Projekt und letzte Chats aus Claude Code übernehmen |
| `/experimental` | Feature-Flags umschalten |
| `/config` | Einstellungen |
| `/usage` | Kontonutzung bzw. Limit-Reset |
| `/status` | Konfiguration, Token-Verbrauch, Limits |
| `/warnings` | gespeicherte Warnungen und Diagnose |
| `/daemon` | lokalen Hintergrundserver verwalten |
| `/feedback` | Logs an die Maintainer senden |
| `/logout` | abmelden |

## Darstellung

`/keymap` (Tasten neu belegen), `/vim` (Vim-Modus), `/raw` (Rohmodus zum Kopieren), `/tui` (TUI-Modus für den nächsten Start), `/theme` (Syntax-Theme), `/statusline`, `/pets`, `/voice`, `/daybreak` (Info zu erweitertem Cybersecurity-Zugang).

## Präfixe und Tasten

`@` Datei per Fuzzy-Suche anhängen · `!` Shell-Befehl (Ausgabe bleibt lokal) · `$` Skill explizit aufrufen · `Enter` während der Ausführung steuert nach · `Tab` reiht Folgeprompt ein · `Esc Esc` vorherige Nachricht bearbeiten · `Ctrl+R` Verlauf suchen · `Ctrl+G` externer Editor · `Alt+,` / `Alt+.` Reasoning senken/heben.

## Änderungen gegenüber Version 0.151

- **Neu im Menü:** `/recap`, `/import`, `/cd`, `/pwd`, `/daemon`, `/warnings`, `/raw`, `/tui`, `/keymap`, `/subagents`, `/delete`, `/plugins`, `/pets`, `/voice`, `/daybreak`, `/usage`, `/config`.
- **Im 0.163-Menü nicht gesehen** (in 0.151 noch genannt): `/apps`, `/debug-config`, `/personality`, `/agent` (jetzt `/agents` und `/subagents`), `/realtime` (schon in 0.151 entfernt). Ob sie ausgeblendet oder entfernt sind, ist nicht geprüft.
- `/title` bedeutet jetzt Terminaltitel-Elemente, nicht Sitzungstitel (dafür `/rename`).

## Terminal-Unterbefehle (außerhalb der TUI)

`codex` · `codex "…"` · `resume` / `fork` (`--last`, `--all`) · `archive` / `unarchive` / `delete` · `agents` · `queue` · `exec` (`--json`, `-o`, `--output-schema`) · `review` (`--uncommitted`, `--base`, `--commit`) · `apply` · `cloud` · `sandbox` · `mcp` · `plugin` · `features` · `doctor` · `update` · `login` / `logout` · `completion` · `remote-control` · `app-server` · `exec-server` · `debug` · `migrate-rollouts`.

Wichtige Flags: `-m`, `-p` (Profil), `-s` (`read-only` · `workspace-write` · `danger-full-access`), `-a` (`on-request` · `never`), `-C`, `--add-dir`, `-i`, `--search`, `--oss`, `-c key=value`, `--strict-config`, `--remote <ADDR>`, `--enable/--disable <FEATURE>`.

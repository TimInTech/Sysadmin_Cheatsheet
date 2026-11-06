# Gemini CLI – Slash-Befehle

Gemini CLI 0.54.0, Stand 2026-10-22. Quelle: <https://geminicli.com/docs/reference/commands>

> [!NOTE] Stand
> Aus der offiziellen Befehlsreferenz vom **2026-10-22**. Die Liste ist dokumentationsbasiert und wurde nicht im TUI gegengeprüft.

## Slash-Befehle

| Befehl | Wirkung / Unterbefehle |
| --- | --- |
| `/about` | Versionsinfo |
| `/agents` | Subagents: `list`, `reload`, `enable <name>`, `disable <name>`, `config <name>` |
| `/auth` | Anmeldeverfahren wechseln |
| `/bug [Titel]` | Issue zu Gemini CLI anlegen |
| `/chat` | Alias für `/resume` (`list`, `save <tag>`, `resume <tag>`, `delete <tag>`, `share [Datei]`, `debug`) |
| `/clear` | Kontext leeren, neue Sitzung |
| `/commands` | eigene `.toml`-Befehle: `list`, `reload` |
| `/compress` | Chat-Kontext durch Zusammenfassung ersetzen |
| `/copy` | letzte Ausgabe kopieren |
| `/directory` (`/dir`) | Workspace-Verzeichnisse: `add <pfad1>,<pfad2>`, `show` |
| `/docs` | Dokumentation im Browser |
| `/editor` | Editor wählen |
| `/extensions` | `config`, `disable`, `enable`, `explore`, `install`, `link`, `list`, `restart`, `uninstall`, `update [name\|--all]` |
| `/help` (`/?`) | Hilfe |
| `/hooks` | `list` (`show`, `panel`), `enable <name>`, `disable <name>`, `enable-all`, `disable-all` |
| `/ide` | `enable`, `disable`, `install`, `status` |
| `/init` | `GEMINI.md` für das Projekt erzeugen |
| `/mcp` | `list` (`ls`), `auth <server>`, `desc`, `disable`, `enable`, `reload`, `schema` |
| `/memory` | `GEMINI.md`-Gedächtnis: `list`, `refresh`, `show` |
| `/model` | `manage`, `set <modell> [--persist]` |
| `/permissions` | Ordner-Vertrauen: `trust [<pfad>]` |
| `/plan` | schreibgeschützter Plan-Modus; `copy` |
| `/policies` | Richtlinien: `list` |
| `/privacy` | Datenschutzhinweis und Einwilligung |
| `/quit` (`/exit`) | beenden; `--delete` löscht auch Verlauf und Temp-Dateien |
| `/restore [tool_call_id]` | Projektdateien vor einem Tool-Lauf wiederherstellen (ohne ID: Checkpoints) |
| `/rewind` | im Verlauf zurückgehen, optional Änderungen rückgängig (`Esc Esc`) |
| `/resume` | Sitzungen und Checkpoints: `list`, `save`, `resume`/`load`, `delete`, `share`, `debug` |
| `/settings` | Einstellungen |
| `/shells` (`/bashes`) | Hintergrund-Shells |
| `/setup-github` | GitHub Actions für Issue-Triage und PR-Review |
| `/skills` | `list`, `enable <name>`, `disable <name>`, `reload` |
| `/stats` | `session` (Standard), `model`, `tools` |
| `/terminal-setup` | Tastenbelegung für mehrzeilige Eingabe |
| `/theme` · `/vim` | Theme · Vim-Modus |
| `/tools [desc\|nodesc]` | Tools auflisten |
| `/upgrade` | Gemini-Code-Assist-Upgrade (nur Google-Login) |

## Präfixe

`@<pfad>` Datei oder Ordner einfügen (Leerzeichen mit `\` maskieren) · `!<befehl>` Shell-Befehl · `!` allein schaltet den Shell-Modus um.

## Terminal

`gemini` · `gemini "…"` · `-p` (headless) · `-i` (Prompt, dann interaktiv) · `-m` · `-r latest\|N` · `--list-sessions` · `--delete-session` · `--approval-mode default\|auto_edit\|yolo\|plan` · `-y` · `-s` (Sandbox) · `-w` (Worktree) · `-o text\|json\|stream-json` · `--include-directories` · `--policy` · `--acp`. Unterbefehle: `gemini mcp`, `extensions`, `skills`, `hooks`, `gemma`.

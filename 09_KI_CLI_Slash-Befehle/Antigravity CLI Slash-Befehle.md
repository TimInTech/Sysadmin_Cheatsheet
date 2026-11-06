---
typ: lernnotiz
erstellt: 2026-10-22
herkunft: ki-synthese
thema: "Antigravity CLI (agy) – Slash-Befehle"
tags: [lernen, ki-befehle, antigravity]
quellen:
  - "Menü der installierten Antigravity CLI 1.4.4 auf Z2 (/ im TUI, 2026-10-22)"
  - "Spickzettel agy_sheet.html (Stand 2026-09-02)"
  - "antigravity.google/docs (CLI-Abschnitt)"
---

# Antigravity CLI (`agy`) – Slash-Befehle

← [[60_Notizen/CLI-Tools/KI-Befehle/KI-Befehle Übersicht|KI-Befehle]]

> [!hinweis] Stand
> Geprüft am **2026-10-22** in **agy 1.4.4**: `/` im TUI geöffnet und das Menü durchgeblättert. Alias in Klammern. Im Menü stehen danach auch alle installierten Skills als `/skill-name`; die sind keine eingebauten Befehle.

## Sitzung

| Befehl | Wirkung |
|---|---|
| `/resume` (`/switch`) | frühere Unterhaltungen durchsuchen und fortsetzen |
| `/rewind` (`/undo`) | zu früherer Nachricht zurückspulen |
| `/fork` (`/branch`) | Unterhaltung an dieser Stelle abzweigen, optional in anderes Projekt |
| `/rename` | Unterhaltung umbenennen |
| `/clear` (`/new`) | Verlauf leeren, neue Unterhaltung |
| `/compact` | Verlauf jetzt zusammenfassen |
| `/copy` | letzte Planner-Antwort kopieren; `/copy n` die n-te, `/copy btw` die /btw-Antwort |
| `/title` | eigenen Terminal-Fenstertitel umschalten |
| `/exit` (`/quit`) | beenden |
| `/logout` | abmelden |

## Arbeiten

| Befehl | Wirkung |
|---|---|
| `/plan` | vor der Ausführung sorgfältig planen |
| `/goal` | bis zum Erreichen des Ziels durcharbeiten |
| `/grill-me` | Agent befragt dich zu Anforderungen, bevor er baut |
| `/boost` | Multi-Agent-Orchestrator für schwierige Aufgaben |
| `/teamwork` | Agententeam für große Projekte (Spickzettel: `/teamwork-preview`) |
| `/browser` | Browser-Agent für Webaufgaben (Chrome) |
| `/learn` | aus Erfolgen und Korrekturen wiederverwendbare Skills oder Regeln ableiten |
| `/schedule` | Anweisung einmalig verzögert oder per Cron wiederkehrend ausführen |
| `/btw` | Nebenfrage ohne Unterbrechung |
| `/diff` | uncommittete Änderungen und Diffs je Zug |
| `/codesearch` (`/cs`) | Code im Workspace suchen |
| `/artifact` | Artifacts ansehen und prüfen |
| `/open` | Datei öffnen oder geöffnete/bearbeitete Dateien ansehen |
| `/agents` | verfügbare eigene Agents |
| `/tasks` | Hintergrundaufgaben |
| `/skills` | verfügbare Skills |
| `/voice` (`/record`) | Prompt per Mikrofon diktieren |

## Kontext, Modell, Rechte

| Befehl | Wirkung |
|---|---|
| `/context` | Kontextauslastung visualisieren |
| `/add-dir` | Verzeichnis zum Workspace hinzufügen |
| `/model` | Modell setzen oder einen einzelnen Prompt mit anderem Modell laufen lassen |
| `/effort` | Reasoning-Aufwand |
| `/usage` (`/quota`) | Modell-Kontingent |
| `/credits` | verbleibende G1-Credits und Kauflink |
| `/permissions` | Tool-Rechte |
| `/config` (`/settings`) | Einstellungen |
| `/mcp` | MCP-Server |
| `/hooks` | Hooks für Tool-Ereignisse |
| `/plugin` | Plugins verwalten, entdecken, installieren |
| `/keybindings` | Tastenbelegung |
| `/statusline` | Statusleiste umschalten |
| `/remote-control` | Fernsteuerung für diese Sitzung (`off` zum Abschalten) |
| `/feedback` · `/changelog` · `/help` | Rückmeldung · Release-Notes · Hilfe |

## Änderungen gegenüber dem Spickzettel

- **Neu:** `/grill-me`, `/learn`, `/schedule`, `/browser`, `/goal`, `/compact`, `/artifact`, `/voice`, `/remote-control`, `/credits`, `/changelog`, `/feedback`.
- **Nicht mehr im Menü gesehen:** `/planning` (ersetzt durch `/plan`, schon im Spickzettel vermerkt), `/conversation`, `/search`, `/teamwork-preview` (jetzt `/teamwork`).
- **Modus-Werte** laut `agy --help`: `--mode` kennt `accept-edits`, `auto`, `plan`; `--effort` kennt `low|medium|high|xhigh|max`. Auf dem Spickzettel stand noch `default` und `high` als höchste Stufe.

## Tasten

`Shift+Tab` Ausführungsmodus wechseln · `Ctrl+R` Artifact-Review · `Tab` Diff-/Tool-Details · `Ctrl+O` Tool-Ausgabe ein/aus · `Ctrl+K` wartende Subagent-Aktion freigeben · `Alt+J` zum nächsten wartenden Subagent · `Ctrl+G` externer Editor · `Esc` Overlay schließen/Stream stoppen · `Ctrl+C` abbrechen (leer zweimal beendet) · `Ctrl+D` beenden · `?` Tastenhilfe. Präfixe: `@` Pfad, `!` Terminalbefehl, `/` Menü.

## Terminal

`agy` · `agy "prompt"` · `agy -i "prompt"` · `agy -c` / `--continue` · `--conversation <id>` · `-p` / `--print` (mit `--output-format text|json|stream-json`, `--json-schema`, `--print-timeout`) · `agy models` · `agy agents` · `agy changelog` · `agy mcp` · `agy plugin` (inkl. `import gemini`) · `agy remote-control` · `agy mic-serve` · `agy update` · `agy install`. Flags: `--model`, `--effort`, `--mode`, `--agent`, `--add-dir`, `--project`, `--new-project`, `--sandbox`, `--remote-control`, `--dangerously-skip-permissions`, `--disable-slash-commands`. Konfiguration: `~/.gemini/antigravity-cli/settings.json`. Startbefehle: [[60_Notizen/CLI-Tools/Agenten- und SSH-Startbefehle]].

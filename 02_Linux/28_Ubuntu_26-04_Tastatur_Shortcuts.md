# 28 Ubuntu 26.04 – Tastatur-Shortcuts (Linux)

Wichtige Tastenkürzel für GNOME (Ubuntu 26.04) und die Bash-Kommandozeile, mit Plasma-Entsprechungen zum Vergleich.

Stand: 2026-11 · Ubuntu 26.04.1 LTS, GNOME Shell 50.1, Wayland-Sitzung.

> [!NOTE]
> Die GNOME-Spalte wurde mit `gsettings` gegen die tatsächlich gesetzten Standardbelegungen geprüft. Die Plasma-Spalte (Kubuntu, Plasma 6) ist nicht gegengeprüft. `Super` ist die Windows-Taste, in Plasma heißt sie `Meta`.

Belegung prüfen oder ändern: *Einstellungen → Tastatur → Tastaturkürzel* oder per Befehl:

```bash
gsettings get org.gnome.desktop.wm.keybindings minimize
gsettings set org.gnome.desktop.wm.keybindings minimize "['<Super>h']"
```

## 1. System und Fenster

| Aktion | Ubuntu (GNOME 50) | Kubuntu (Plasma) |
|---|---|---|
| Aktivitäten / Anwendungsübersicht | `Super` (Übersicht), `Super + A` (Anwendungen) | `Meta` (Anwendungsmenü) |
| Fenster schließen | `Alt + F4` | `Alt + F4` |
| Fenster minimieren | `Super + H` | `Meta + F9` |
| Fenster maximieren / wiederherstellen | `Super + ↑` / `Super + ↓`; `Alt + F10` schaltet um | `Meta + F10` |
| Fenster auf anderen Monitor | `Super + Shift + ←/→` | `Meta + Shift + ←/→` |
| Zwischen Anwendungen wechseln | `Alt + Tab` oder `Super + Tab` | `Alt + Tab` |
| Zwischen Fenstern einer Anwendung | `Super + ^` (Taste über Tab) oder `Alt + ^` | – |
| Arbeitsfläche wechseln | `Ctrl + Alt + ←/→/↑/↓` oder `Super + Bild↑/↓` | `Ctrl + F1/F2/F3 …` |
| Fenster auf andere Arbeitsfläche | `Ctrl + Shift + Alt + ←/→` | – |
| Terminal öffnen | `Ctrl + Alt + T` | `Ctrl + Alt + T` |
| Benachrichtigungen | `Super + V` oder `Super + M` | – |
| Eingabesprache wechseln | `Super + Leertaste` | – |
| Abmelden-Dialog | `Ctrl + Alt + Entf` | – |
| Emoji-Auswahl | `Ctrl + .` (in Textfeldern) | `Meta + .` |

> [!NOTE]
> In GNOME 50 sind standardmäßig **nicht** belegt: Dateimanager (`Super + E`), Desktop anzeigen (`Super + D`) und Fenster links/rechts kacheln (`Super + ←/→`). Wer sie braucht, legt sie unter *Tastaturkürzel* selbst an.

## 2. Screenshots

| Aktion | Ubuntu (GNOME) |
|---|---|
| Screenshot-Oberfläche (Bereich, Fenster, Bildschirm, Aufnahme) | `Druck` |
| Ganzer Bildschirm sofort | `Shift + Druck` |
| Aktuelles Fenster sofort | `Alt + Druck` |

KDE: `Druck` startet Spectacle, die Bereichsaufnahme wird in den Plasma-Einstellungen festgelegt.

## 3. Terminal (Bash/Readline, in jeder Umgebung)

| Aktion | Shortcut |
|---|---|
| Laufenden Befehl abbrechen | `Ctrl + C` |
| Autovervollständigen | `Tab` (zweimal: Vorschläge) |
| Vorheriger / nächster Befehl | `↑` / `↓` |
| Verlauf rückwärts durchsuchen | `Ctrl + R` |
| Terminal leeren | `Ctrl + L` |
| Anfang / Ende der Zeile | `Ctrl + A` / `Ctrl + E` |
| Wort davor löschen | `Ctrl + W` |
| Zeile bis Anfang löschen | `Ctrl + U` |
| Zeile bis Ende löschen | `Ctrl + K` |
| Prozess anhalten | `Ctrl + Z`, danach `bg` oder `fg` |
| Eingabe beenden / Shell verlassen | `Ctrl + D` |
| Letzten Befehl wiederholen | `!!` (z. B. `sudo !!`) |
| Kopieren / Einfügen im Standard-Terminal Ptyxis | `Ctrl + Shift + C` / `Ctrl + Shift + V` |
| Neuer Terminal-Tab | `Ctrl + Shift + T` |

`Ctrl + Z` hält den Prozess nur an, er wird nicht beendet. Mit `jobs` auflisten, mit `fg` zurückholen.

## 4. Allgemein

| Aktion | Shortcut |
|---|---|
| Suche im Fenster oder Text | `Ctrl + F` |
| Hilfe | `Super + F1` |

Zur Tastaturbelegung (DE/UK, Sonderzeichen): [Tastaturbelegung DE und UK](29_Tastaturbelegung_DE_UK.md).

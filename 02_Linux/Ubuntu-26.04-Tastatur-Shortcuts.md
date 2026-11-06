# Ubuntu 26.04 – Tastatur-Shortcuts

Stand: 2026-11-01 · Ubuntu 26.04.1 LTS (Resolute Raccoon), GNOME Shell 50.1, Wayland-Sitzung.
← [[60_Notizen/Lernen/Lernnotizen|Lernnotizen]] · Verwandt: [[Ubuntu-26.04-Terminal-und-Anwendungen]] · [[20_Systeme/Kubuntu/Kubuntu-Migration-auf-neue-NVMe|Kubuntu-Notizen]]

> Die GNOME-Spalte wurde auf diesem Rechner mit `gsettings` gegen die tatsächlich gesetzten Standardbelegungen geprüft. Die Plasma-Spalte stammt aus der Altfassung (Kubuntu, Plasma 6) und ist hier **nicht verifiziert**. Linux Mint (Cinnamon) ist kein Teil von Ubuntu 26.04 und wurde aus der Tabelle entfernt.

Prüfen oder ändern: *Einstellungen → Tastatur → Tastaturkürzel* (GNOME) beziehungsweise `gsettings get org.gnome.desktop.wm.keybindings <schlüssel>`. `Super` ist die Windows-Taste, in Plasma heißt sie `Meta`.

## System und Fenster

| Aktion | Ubuntu (GNOME 50, verifiziert) | Kubuntu (Plasma, unverifiziert) |
|---|---|---|
| Aktivitäten / Anwendungsübersicht | `Super` (Übersicht), `Super + A` (Anwendungen) | `Meta` (Anwendungsmenü) |
| Fenster schließen | `Alt + F4` | `Alt + F4` |
| Fenster minimieren | `Super + H` | `Meta + F9` |
| Fenster maximieren / wiederherstellen | `Super + ↑` / `Super + ↓` (auch `Alt + F5`); `Alt + F10` schaltet um | `Meta + F10` |
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

**Nicht belegt (GNOME-Standard auf diesem Rechner):** Dateimanager (`Super + E`), Desktop anzeigen (`Super + D`), Fenster links/rechts kacheln (`Super + ←/→`). Wer sie braucht, legt sie unter *Tastaturkürzel* selbst an. Die Altfassung nannte sie als Standard; das stimmt für Ubuntu 26.04 nicht.

## Screenshots

| Aktion | Ubuntu (GNOME) |
|---|---|
| Screenshot-Oberfläche (Bereich, Fenster, Bildschirm, Aufnahme) | `Druck` |
| Ganzer Bildschirm sofort | `Shift + Druck` |
| Aktuelles Fenster sofort | `Alt + Druck` |

KDE: `Druck` startet Spectacle; Bereichsaufnahme siehe Plasma-Einstellungen.

## Terminal (Bash/Readline, gilt in jeder Umgebung)

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
| Prozess anhalten (Hintergrund) | `Ctrl + Z`, danach `bg` oder `fg` |
| Eingabe beenden / Shell verlassen | `Ctrl + D` |
| Letzten Befehl wiederholen | `!!` (z. B. `sudo !!`) |
| In Ptyxis (Standard-Terminal in 26.04) kopieren / einfügen | `Ctrl + Shift + C` / `Ctrl + Shift + V` |
| Neuer Terminal-Tab | `Ctrl + Shift + T` |

Hinweis `Ctrl + Z`: Der Prozess wird angehalten, nicht beendet. Mit `jobs` auflisten, mit `fg` zurückholen.

## Allgemein

- Suche im Fenster oder Text: `Ctrl + F`
- Hilfe: `Super + F1`

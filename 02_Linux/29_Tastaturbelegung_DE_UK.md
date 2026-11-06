# 29 Tastaturbelegung DE (QWERTZ) und UK (QWERTY) (Linux)

Unterschiede der beiden Layouts, Sonderzeichen per AltGr und das Umschalten des Layouts unter Linux.

## 1. Zahlenreihe und Sonderzeichen im Vergleich

| Taste | DE (QWERTZ) | UK (QWERTY) |
|---|---|---|
| links neben `1` | `^` `°` | `` ` `` `¬` |
| `2` | `2` `"` | `2` `"` |
| `3` | `3` `§` | `3` `£` |
| `4` | `4` `$` | `4` `$` |
| `6` | `6` `&` | `6` `^` |
| `7` | `7` `/` | `7` `&` |
| `8` | `8` `(` | `8` `*` |
| `9` | `9` `)` | `9` `(` |
| `0` | `0` `=` | `0` `)` |
| rechts neben `0` | `ß` `?` | `-` `_` |
| nächste Taste | `´` `` ` `` | `=` `+` |
| rechts neben `P` | `Ü`, danach `+` `*` | `[` `{`, danach `]` `}` |
| rechts neben `L` | `Ö`, `Ä`, danach `#` `'` | `;` `:`, `'` `@`, danach `#` `~` |
| links neben der unteren Buchstabenreihe | `<` `>` | `\` `\|` |
| Buchstaben `Z` / `Y` | `Z` mittlere, `Y` untere Reihe | `Y` mittlere, `Z` untere Reihe |
| rechts neben `M` | `,` `;`, `.` `:`, `-` `_` | `,` `<`, `.` `>`, `/` `?` |

Nur DE: Umlaute `Ä Ö Ü` und `ß`. Nur UK: `£` und `¬`.

## 2. Sonderzeichen per AltGr (DE-Layout)

| Zeichen | Tasten |
|---|---|
| `@` | `AltGr + Q` |
| `€` | `AltGr + E` |
| `\` | `AltGr + ß` |
| `[` `]` | `AltGr + 8` / `AltGr + 9` |
| `{` `}` | `AltGr + 7` / `AltGr + 0` |
| `\|` | `AltGr + <` |
| `~` | `AltGr + +` |
| `µ` | `AltGr + M` |

Unter Linux erscheint `AltGr` teils als `ISO_Level3_Shift`. Zeichen mit der Compose-Taste oder per Unicode eingeben: `Ctrl + Shift + U`, Code, `Enter`.

## 3. Layout unter Linux umschalten

```bash
# Aktuelles Layout anzeigen
localectl status

# Systemweit setzen (wirkt auch in der Konsole)
sudo localectl set-x11-keymap de
sudo localectl set-keymap de

# Nur die laufende X11-Sitzung (unter Wayland nicht zuverlässig)
setxkbmap de
setxkbmap gb

# GNOME: Eingabequellen anzeigen und setzen (Wechsel mit Super + Leertaste)
gsettings get org.gnome.desktop.input-sources sources
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'de'), ('xkb', 'gb')]"
```

> [!NOTE]
> Das UK-Layout heißt in XKB `gb`. Das Layout in der Konsole (TTY) kommt aus `localectl set-keymap`, das in der grafischen Sitzung aus den Eingabequellen.

Weitere Tastenkürzel: [Ubuntu 26.04 Tastatur-Shortcuts](28_Ubuntu_26-04_Tastatur_Shortcuts.md).

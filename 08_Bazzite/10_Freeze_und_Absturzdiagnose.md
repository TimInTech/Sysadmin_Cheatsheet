# 10 Freeze- und Absturzdiagnose

Diese Seite ist eine Schritt-für-Schritt-Anleitung für Fedora-basierte Systeme (Fedora Workstation, Nobara, Bazzite), die einfrieren, von selbst neu starten oder bei denen die Oberfläche abstürzt.

Sie ist zum Weitergeben gedacht und setzt kein Vorwissen voraus: **ein Befehl nach dem anderen, kopieren und einfügen**. Abschnitt 1 bis 10 ist zum Ausführen, Abschnitt 11 ist für die Person, die bei der Auswertung hilft.

> **Alle Befehle lesen nur aus.** Es wird nichts installiert, nichts gelöscht und nichts an Treibern, Kernel oder Einstellungen geändert.

## 1. Terminal öffnen

1. Auf der Tastatur `Strg` + `Alt` + `T` drücken (englische Tastatur: `Ctrl` + `Alt` + `T`). Damit öffnet sich das Terminal.
2. Klappt das nicht: Anwendungsmenü öffnen und nach `Terminal` oder `Konsole` suchen.
3. Kopieren im Terminal mit `Strg` + `Umschalt` + `C`, einfügen mit `Strg` + `Umschalt` + `V`.

Für jeden Befehl auf dieser Seite gilt:

| Regel | Warum |
|---|---|
| Immer nur **einen** Befehl kopieren | Mehrere auf einmal erzeugen Fehler, die niemand zuordnen kann |
| Nach dem Einfügen `Enter` drücken und warten | Manche Befehle brauchen ein paar Sekunden |
| Passwort-Eingabe bleibt leer | Das Terminal zeigt keine Passwörter an. Einfach tippen und `Enter` drücken |
| Bei stockender Ausgabe nicht mehrfach `Enter` drücken | Nur warten, sonst kommen Befehle doppelt an |
| Nichts selbst reparieren | Erst Ergebnisse zurückschicken, dann wird entschieden |

## 2. Was ist überhaupt passiert?

Dieser Abschnitt ist nur zum Notieren, hier ist kein Befehl nötig. Die Antwort hilft später bei der Auswertung.

| Beobachtung | Was das meistens bedeutet |
|---|---|
| Nichts reagiert mehr, kein Bildwechsel, kein Mauszeiger | Kompletter Freeze des ganzen Systems |
| Der Rechner startet von selbst neu | Absturz oder Notabschaltung |
| Das Bild steht, aber man kommt mit `Strg` + `Alt` + `F3` in ein Text-Terminal | Problem in der Oberfläche oder im Grafiktreiber |
| Es passiert nur in Spielen, Videos oder beim Kopieren großer Dateien | Belastung, Kühlung, Netzteil oder Datenträger |

## 3. Liste der letzten Systemstarts

```bash
journalctl --list-boots
```

Die Ausgabe ist eine Liste von Starts. Wichtig ist die erste Spalte:

| Eintrag | Bedeutung |
|---|---|
| `0` | Der Start, der gerade läuft |
| `-1` | Der Start davor, also der abgestürzte |
| `-2`, `-3` … | Noch ältere Starts |

## 4. Fehler vom abgestürzten Start anzeigen

```bash
sudo journalctl -b -1 -p warning..alert --no-pager
```

Das ist der wichtigste Befehl, wenn der Rechner nach dem Absturz neu gestartet wurde. Er zeigt Warnungen und Fehler des Starts davor.

Wenn der Rechner **nicht** neu gestartet wurde, sondern gerade hängt oder läuft, stattdessen den laufenden Start anzeigen:

```bash
sudo journalctl -b -p warning..alert --no-pager
```

Die Ausgabe darf lang sein. Sie muss nicht gelesen oder verstanden werden, sie wird am Ende zurückgeschickt.

## 5. Nach bekannten Fehlerwörtern suchen

```bash
sudo journalctl -b -1 -k --no-pager | grep -Ei 'error|fail|fault|panic|oops|watchdog|hang|lockup|segfault|amdgpu|nvidia|nouveau|i915|gpu|nvme|ata|i/o|thermal|overheat|mce|hardware error'
```

Der Teil in Anführungszeichen ist eine Suchliste. Es müssen nicht alle Wörter verstanden werden. Diese Tabelle erklärt, was ein Treffer bedeutet:

| Gefundenes Wort | Bedeutet |
|---|---|
| `panic`, `oops` | Der Kernel selbst ist abgestürzt |
| `watchdog`, `lockup`, `hang` | Das System hat sich aufgehängt und ist eingefroren |
| `amdgpu`, `i915`, `nouveau`, `nvidia`, `drm` | Meldung vom Grafiktreiber |
| `nvme`, `ata`, `i/o error`, `timeout` | Der Datenträger hat nicht geantwortet |
| `thermal`, `overheat` | Temperaturproblem, Kühlung oder Lüfter |
| `mce`, `hardware error`, `EDAC` | Hardwarefehler, zum Beispiel Arbeitsspeicher |
| `segfault` | Ein einzelnes Programm ist abgestürzt, nicht das System |

## 6. Abgestürzte Programme prüfen

```bash
coredumpctl list --no-pager
```

Das zeigt Programme, die abgestürzt sind und einen Bericht hinterlassen haben. Bleibt die Ausgabe leer, ist das kein Fehler und kein Beweis für ein gesundes System.

## 7. Angaben zum Rechner

Hier ist es in Ordnung, alles auf einmal einzufügen. Die Befehle sind nur Ansagen und ändern nichts.

```bash
echo "=== SYSTEM ==="
cat /etc/os-release

echo
echo "=== KERNEL ==="
uname -a

echo
echo "=== GRAFIK ==="
lspci -nnk | grep -A4 -Ei 'VGA|3D|Display'

echo
echo "=== PROZESSOR ==="
lscpu | grep -E 'Model name|Vendor ID'

echo
echo "=== ARBEITSSPEICHER ==="
free -h
```

Nur auf Bazzite und anderen Fedora-Atomic-Systemen. Dort ist der Befehl optional:

```bash
rpm-ostree status -v
```

## 8. Alles in eine Datei speichern

Jetzt dieselben Befehle noch einmal, diesmal landen die Ausgaben in einer Datei. Zeile für Zeile kopieren, einfügen, `Enter` drücken, warten.

```bash
journalctl --list-boots 2>&1 | tee ~/freeze-diagnose.txt
```

```bash
sudo journalctl -b -1 -p warning..alert --no-pager 2>&1 | tee -a ~/freeze-diagnose.txt
```

```bash
sudo journalctl -b -1 -k --no-pager 2>&1 | tee -a ~/freeze-diagnose.txt
```

```bash
coredumpctl list --no-pager 2>&1 | tee -a ~/freeze-diagnose.txt
```

```bash
cat /etc/os-release | tee -a ~/freeze-diagnose.txt
```

```bash
uname -a | tee -a ~/freeze-diagnose.txt
```

```bash
lscpu | grep -E 'Model name|Vendor ID' | tee -a ~/freeze-diagnose.txt
```

```bash
free -h | tee -a ~/freeze-diagnose.txt
```

Das `tee` schreibt die Ausgabe in die Datei und zeigt sie gleichzeitig an. `tee -a` hängt an und löscht nichts. Das `2>&1` sorgt dafür, dass auch Fehlermeldungen in der Datei landen.

## 9. Datei zurückschicken

1. Dateimanager öffnen (bei Bazzite und Nobara heißt er `Dolphin` oder `Dateien`).
2. In den **Persönlichen Ordner** gehen. Das ist der Zuhause-Ordner, oft mit einem Häuschen-Symbol.
3. Darin liegt jetzt `freeze-diagnose.txt`.
4. Diese eine Datei über Chat, Messenger oder Mail zurückschicken. Wenn sie zu groß ist: `Rechtsklick` → `Komprimieren` und die Archivdatei schicken.

Fertig. Damit ist die Auswertung möglich, ohne dass jemand auf den Rechner zugreifen muss.

## 10. Was du auf keinen Fall machen sollst

- Nichts neu installieren und das System nicht neu aufsetzen.
- Keine Befehle aus Foren, Videos oder Suchmaschinen ausführen, auch wenn sie passend klingen.
- `sudo dnf install`, `sudo dnf remove` und `sudo apt install` nicht verwenden. Sie lösen ein Freeze-Problem nicht.
- Kernel, Treiber, GRUB und Energie-Einstellungen nicht ändern.
- `freeze-diagnose.txt` nicht löschen und den Rechner bis zur Auswertung möglichst nicht weiter belasten.
- Festplatten nicht selbst prüfen, formatieren oder Partitionen ändern.

## 11. Für die auswertende Person

Diese Befehle gehören zur Auswertung und nicht in die Anleitung für den Anwender.

```bash
sudo journalctl -b -1 -p err -o short-precise --no-pager
sudo journalctl -b -1 -k -p err --no-pager
sudo dmesg --level=err,warn --time-format=iso
coredumpctl info PID --no-pager
coredumpctl --no-pager status
systemctl --failed
df -hT
sudo smartctl -x /dev/nvme0
sensors
```

Zuordnung von Befund zu nächstem Schritt:

| Befund | Nächster Schritt |
|---|---|
| Grafiktreiber-Meldungen, schwarzer Bildschirm | Kernelversion vergleichen, anderes Deployment booten, Treiberstand prüfen |
| Datenträger-Timeouts, I/O-Fehler | Laufwerksgesundheit auswerten, keine Schreibreparatur auf verdächtigen Datenträgern |
| Temperatur- oder lastabhängig | Kühlung und Netzteil prüfen, Lastprofile beobachten |
| `mce`, `EDAC`, Hardwarefehler | Arbeitsspeicher und Prozessor separat testen, kein Softwareeingriff |
| Erst nach einem Update | Vorheriges Deployment booten (`rpm-ostree status -v`, Auswahl im GRUB-Menü, alternativ `sudo rpm-ostree rollback`) |
| Nur eine Anwendung betroffen | Anwendungsproblem, Core-Dump auswerten, System unangetastet lassen |

Grundsatz: erst auswerten, dann eingreifen. Jeder Eingriff am Gerät braucht vorher einen Rückweg, also ein Backup oder ein bootfähiges vorheriges Deployment.

## 12. Weiterführende Quellen

- [systemd: journalctl](https://www.freedesktop.org/software/systemd/man/latest/journalctl.html) – Bootauswahl, Prioritätsfilter und Ausgabeformate.
- [systemd: coredumpctl](https://www.freedesktop.org/software/systemd/man/latest/coredumpctl.html) – Core-Dumps auflisten und auswerten.
- [Fedora: Troubleshooting](https://docs.fedoraproject.org/en-US/quick-docs/troubleshooting/) – Systemdiagnose auf Fedora-Basis.
- [kernel.org: Bericht von Kernelfehlern](https://www.kernel.org/doc/html/latest/admin-guide/reporting-issues.html) – Panic, Oops und Lockup einordnen.

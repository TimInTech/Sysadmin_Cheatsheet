# 10 Freeze- und Absturzdiagnose

Diese Seite enthält die Erstdiagnose für Fedora-basierte Systeme (Fedora Workstation, Nobara, Bazzite), die einfrieren, unerwartet neu starten oder deren Oberfläche abstürzt.

> **Wichtig:** Alle Befehle auf dieser Seite sind rein lesend. Es werden keine Kernelargumente, Treiber, Energieprofile oder Deployments verändert. Erst auswerten, dann gezielt und reversibel eingreifen.

## 1. Fehlerbild zuerst eingrenzen

Vor der Logauswertung klären, wie der Rechner tatsächlich ausgestiegen ist. Davon hängt ab, welcher Boot und welcher Logbereich relevant ist.

| Beobachtung | Wahrscheinlicher Bereich | Erste Prüfung |
|---|---|---|
| Kompletter Freeze: keine Reaktion auf Tastatur, kein Ping, kein SSH | Kernel, GPU-Treiber, Datenträger-I/O, thermische Abschaltung | `journalctl -b -1`, Kernellog, `coredumpctl` |
| Spontaner Neustart ohne Vorwarnung | Netzteil/Akku, thermische Notabschaltung, Kernel-Panic, Watchdog | `journalctl -b -1`, Kerneleinträge, `pstore` |
| Nur die Oberfläche hängt, SSH antwortet weiter | GPU-Treiber, Wayland-Session, einzelne Anwendung | User-Journal, `coredumpctl`, GPU-Kernellog |
| Hänger nur unter Last | Netzteil, Kühlung, RAM, SSD/NVMe | Temperaturen, SMART, Speicherdiagnose |
| Hänger nach einem Update | Regression im neuen Deployment oder Kernel | `rpm-ostree status -v`, vorheriger Boot |

## 2. Letzte Systemstarts anzeigen

```bash
journalctl --list-boots
```

Die Ausgabe listet jeden Boot mit Index, Boot-ID und Zeitfenster.

| Angabe | Bedeutung |
|---|---|
| `0` | Aktuell laufender Boot |
| `-1` | Vorheriger Boot, also der abgestürzte Start |
| `-2`, `-3` … | Ältere Starts, nützlich für wiederkehrende Fehler |

Faustregel: Nach einem Freeze mit anschließendem Neustart ist `-1` der interessante Boot. Bei einem Hänger ohne Neustart ist `0` relevant.

## 3. Fehler des vorherigen Starts anzeigen

```bash
sudo journalctl -b -1 -p warning..alert --no-pager
```

Diese Ausgabe ist der wichtigste Einzelbefehl, wenn der Rechner nach dem Absturz neu gestartet wurde. Sie zeigt Warnungen bis zu schweren Fehlern des vorherigen Boots.

Ergänzend für den laufenden Boot:

```bash
sudo journalctl -b -p warning..alert --no-pager
```

Auf Bazzite und anderen Fedora-Atomic-Systemen zusätzlich den Deployment-Stand prüfen. So lässt sich ein Hänger nach einem Update von einem Hardwareproblem trennen:

```bash
rpm-ostree status -v
```

> **Hinweis:** Nach einem Freeze mit hartem Ausschalten kann der letzte Journalblock unvollständig sein, weil Journald die letzten Sekunden nicht mehr schreiben konnte. Fehlende Einträge sind kein Beweis für einen fehlerfreien Verlauf.

## 4. Gezielt nach Absturzursachen suchen

Im vorherigen Boot im Kernellog nach typischen Auslösern filtern:

```bash
sudo journalctl -b -1 -k --no-pager | grep -Ei 'error|fail|fault|panic|oops|watchdog|hang|lockup|segfault|amdgpu|nvidia|nouveau|i915|gpu|nvme|ata|i/o|thermal|overheat|mce|hardware error'
```

Bedeutung der wichtigsten Treffer:

| Treffer | Bedeutet | Typischer Verdacht |
|---|---|---|
| `panic`, `oops`, `BUG:` | Kernel bricht ab | Kernel-/Treiberregression |
| `watchdog`, `lockup`, `hang` | Kernel- oder CPU-Hänger, Soft-/Hard-Lockup | Treiber, Firmware, Energieverwaltung |
| `amdgpu`, `i915`, `nouveau`, `nvidia`, `drm` | Grafiktreiber-Meldungen | GPU-Treiber oder GPU-Defekt |
| `nvme`, `ata`, `i/o error`, `timeout` | Datenträger antwortet nicht | SSD/NVMe, Controller, Kabel |
| `thermal`, `overheat` | Temperaturgrenze erreicht | Kühlung, Lüfter, Staub |
| `mce`, `hardware error`, `EDAC` | Hardwarefehler der CPU oder des Speichers | RAM, CPU, Mainboard |
| `segfault` | Anwendungsabsturz | Einzelnes Programm, nicht das System |

Zusätzlich die Fehlerstufen getrennt ansehen:

```bash
sudo journalctl -b -1 -k -p err --no-pager
sudo journalctl -b -1 -p err -o short-precise --no-pager
```

Der Kernel-Ringpuffer mit `dmesg` zeigt immer nur den aktuell laufenden Boot:

```bash
sudo dmesg --level=err,warn --time-format=iso
```

## 5. Core-Dumps prüfen

Abgestürzte Anwendungen und Sitzungskomponenten legen Core-Dumps ab:

```bash
coredumpctl list --no-pager
coredumpctl info PID --no-pager
```

Die PID stammt aus der Liste. Ein Core-Dump erklärt den Absturz einer Anwendung oder der Sitzung, aber keinen Kernel-Freeze. Ein leeres Ergebnis schließt einen Hardware- oder Kerneldefekt nicht aus.

Deaktivierte Core-Dumps prüfen:

```bash
coredumpctl --no-pager status
```

## 6. Hardware- und Systembasis erfassen

Diese Angaben gehören zu jeder Fehlermeldung dazu:

```bash
echo "=== SYSTEM ==="
cat /etc/os-release

echo
echo "=== KERNEL ==="
uname -a

echo
echo "=== GPU ==="
lspci -nnk | grep -A4 -Ei 'VGA|3D|Display'

echo
echo "=== CPU ==="
lscpu | grep -E 'Model name|Vendor ID'

echo
echo "=== RAM ==="
free -h
```

Ergänzend bei Fedora-Atomic-Systemen:

```bash
rpm-ostree status -v
systemctl --failed
df -hT
```

## 7. Auswertung und nächste Schritte

1. Wenn der Rechner nach dem Absturz neu gestartet wurde, zuerst die Schritte 2 und 3 abarbeiten. Sie enthalten die entscheidenden Hinweise.
2. Auffällige Treffer aus Schritt 4 zeitlich mit dem letzten bekannten Aktivitätszeitpunkt vergleichen.
3. Core-Dumps aus Schritt 5 nur dann als Ursache werten, wenn sie zum Fehlerbild passen.
4. Die Auswertung abschließen, **bevor** Treiber, Kernelversionen, Energieverwaltung oder Kernelparameter geändert werden.

Dem Fehlerbild zugeordnete Anschlussdiagnose:

| Befund | Nächster Schritt |
|---|---|
| GPU-Treibermeldungen, Blackscreen | Anderes Deployment booten, Kernelversion vergleichen, Treiberstand prüfen |
| Datenträger-Timeouts, I/O-Fehler | Laufwerksgesundheit prüfen, siehe [04 SMART und Festplattendiagnose](../03_Datenrettung_und_Forensik/04_SMART_und_Festplattendiagnose.md) |
| Temperatur- oder Lastabhängigkeit | Kühlung und Netzteil prüfen, Lastprofile beobachten |
| Hardwarefehler (`mce`, `EDAC`) | RAM und CPU separat testen, kein Softwareeingriff |
| Absturz nur nach einem Update | Vorheriges Deployment booten, siehe [02 Updates, Deployments, Rebase, Recovery](02_Updates_Deployments_Rebase_Recovery.md) |

## 8. Diagnoseausgabe sichern

Vor jedem Eingriff die Logs in eine Datei schreiben, damit die Beweislage erhalten bleibt und ein späterer Vergleich möglich ist:

```bash
{
  journalctl --list-boots
  sudo journalctl -b -1 -p warning..alert --no-pager
  sudo journalctl -b -1 -k --no-pager
  coredumpctl list --no-pager
  rpm-ostree status -v
  uname -a
} | tee ~/freeze-diagnose-$(date +%F).log
```

## 9. Was hier bewusst nicht gemacht wird

- Keine Änderung an Treibern, Kernelparametern, Energieverwaltung, GRUB oder Layern, solange die Logs nicht ausgewertet sind.
- Keine Kernelversion und kein Deployment wechseln, nur weil ein Verdacht besteht.
- Kein Löschen oder Rotieren von Journal und Core-Dumps vor der Sicherung der Ausgabe.
- Keine Befehle aus fremden Anleitungen ungeprüft übernehmen. Auf Fedora-Atomic-Systemen gilt weiterhin der Hinweis aus dem [Bazzite-Einstieg](README.md): `sudo apt install` und `sudo dnf install` verändern das laufende System nicht dauerhaft.

## 10. Weiterführende Quellen

- [systemd: journalctl](https://www.freedesktop.org/software/systemd/man/latest/journalctl.html) – Bootauswahl, Prioritätsfilter und Ausgabeformate.
- [systemd: coredumpctl](https://www.freedesktop.org/software/systemd/man/latest/coredumpctl.html) – Core-Dumps auflisten und auswerten.
- [Fedora: Troubleshooting](https://docs.fedoraproject.org/en-US/quick-docs/troubleshooting/) – Systemdiagnose auf Fedora-Basis.
- [kernel.org: Bericht von Kernelfehlern](https://www.kernel.org/doc/html/latest/admin-guide/reporting-issues.html) – Panic, Oops und Lockup einordnen.

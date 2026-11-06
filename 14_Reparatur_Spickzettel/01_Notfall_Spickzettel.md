# 01 Reparatur-Spickzettel: Wenn nichts mehr geht

Diese Seite ist der Wegweiser für den Ernstfall: Der Rechner startet nicht, ein Passwort ist weg oder die Festplatte macht Geräusche. Sie sagt dir, **was du zuerst tust**, und verweist für die langen Anleitungen auf die vorhandenen Seiten dieses Repositories. Doppelte Befehlslisten gibt es hier bewusst nicht.

> **Hinweis:** Die Befehle sind gegen die Hilfe der Werkzeuge (smartctl, ntfsfix) und die bestehenden Seiten geprüft. Die Windows-Schritte konnten ohne Windows-Rechner nicht ausgeführt werden und sind als *nicht getestet* gekennzeichnet.

> **Warnung:** Bei einer defekten Festplatte gilt: **Nicht weiterbenutzen, nicht reparieren, zuerst retten.** Jeder Schreibzugriff und jeder Reparaturversuch (`chkdsk /f`, `fsck`) kann Daten endgültig zerstören. Erst ein Abbild ziehen (Abschnitt 5), dann reparieren.

## 1. Erste Hilfe: Was ist kaputt?

| Was passiert | Erster Schritt | Weiter bei |
| --- | --- | --- |
| Windows startet nicht (schwarzer Bildschirm, Boot-Schleife) | Rettungsstick bereithalten, Abschnitt 2 | [Windows RE](../04_Rettungsmedien_und_Live_Systeme/03_Windows_RE.md) |
| Linux startet nicht (GRUB-Fehler, `grub rescue>`) | Live-Stick starten, Abschnitt 3 | [Chroot](../04_Rettungsmedien_und_Live_Systeme/02_Chroot_Umgebungen.md) |
| Passwort vergessen | Abschnitt 4 | [Benutzerverwaltung](../01_Windows_11/05_Benutzer_und_Rechteverwaltung.md) |
| Festplatte klackert, hängt, Dateien verschwinden | Sofort ausschalten, Abschnitt 5 | [Klonen und Imaging](../03_Datenrettung_und_Forensik/01_Klonen_und_Imaging.md) |
| Unsicher, ob die Platte gesund ist | Abschnitt 6 | [SMART](../03_Datenrettung_und_Forensik/04_SMART_und_Festplattendiagnose.md) |

Einen Rettungsstick erstellst du mit [Ventoy](../04_Rettungsmedien_und_Live_Systeme/01_Ventoy_und_ISOs.md). Die Download-Links stehen unter [Download-Links](../04_Rettungsmedien_und_Live_Systeme/04_Download_Links.md). Lege den Stick **vor** dem Notfall an.

## 2. Windows startet nicht

Reihenfolge von harmlos bis gründlich:

1. **Ruhe bewahren, alles abziehen.** USB-Sticks, Dockingstation, Drucker trennen und neu starten. Manchmal blockiert ein Gerät den Start.
2. **Automatische Reparatur abwarten.** Windows startet nach zwei fehlgeschlagenen Starts selbst die Wiederherstellungsumgebung (blauer Bildschirm "Automatische Reparatur"). Wähle **Erweiterte Optionen -> Problembehandlung -> Erweiterte Optionen**.
3. **Dort der Reihe nach probieren:**
   - **Starthilfe** (Startreparatur)
   - **Systemwiederherstellung**, falls ein Wiederherstellungspunkt existiert
   - **Starteinstellungen -> Abgesicherter Modus**
   - **Eingabeaufforderung** für die Befehle unten

Aus einem laufenden Windows lässt sich die Wiederherstellungsumgebung auch direkt öffnen:

```cmd
shutdown /r /o /t 0
```

In der Eingabeaufforderung der Wiederherstellung zuerst die Laufwerksbuchstaben klären, sie weichen oft ab:

```cmd
diskpart
list volume
exit
dir C:\
```

Danach die Reparatur der Startdateien und der Systemdateien: Schritt für Schritt in [Windows RE](../04_Rettungsmedien_und_Live_Systeme/03_Windows_RE.md) (Abschnitte 1 und 2 für den Start, Abschnitt 3 für SFC und DISM). Die Prüfung der Wiederherstellungsumgebung:

```cmd
reagentc /info
```

Zeigt sie *Disabled* an, existiert keine nutzbare Wiederherstellung. Dann hilft nur der Rettungsstick. Nicht getestet.

> **Warnung:** Ist das Laufwerk mit **BitLocker** verschlüsselt, fragt die Wiederherstellung nach dem **Wiederherstellungsschlüssel**. Ohne ihn kommst du nicht an die Daten. Den Schlüssel findest du im Microsoft-Konto unter `https://aka.ms/myrecoverykey`. Mehr: [BitLocker und TPM](../01_Windows_11/09_BitLocker_und_TPM.md).

Wenn alles scheitert und Daten wichtig sind: **Erst Daten sichern** (Abschnitt 5 oder von einem Linux-Live-Stick kopieren), dann Windows neu installieren: [Ersteinrichtung](../11_Ersteinrichtung/01_Checkliste_Windows_und_Ubuntu.md).

## 3. GRUB reparieren (Linux)

Startet Linux mit `grub>` oder `grub rescue>` oder gar nicht mehr, ist meist der Bootloader beschädigt, oft nach einer Windows-Installation daneben.

1. Von einem Ubuntu-Live-Stick starten ("Ubuntu ausprobieren").
2. Das System einhängen und in die Chroot wechseln: [Chroot-Umgebungen, Abschnitt 1](../04_Rettungsmedien_und_Live_Systeme/02_Chroot_Umgebungen.md).
3. Grub neu installieren und die Konfiguration erzeugen: [Chroot, Abschnitt 2.1](../04_Rettungsmedien_und_Live_Systeme/02_Chroot_Umgebungen.md) und [Systemreparatur, Abschnitt 2](../02_Linux/02_Systemreparatur.md).

Die wichtigste Vorbereitung, die oft vergessen wird: Erst feststellen, ob das System im UEFI- oder BIOS-Modus läuft.

```bash
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "BIOS (Legacy)"
lsblk -f
```

Bei UEFI muss die EFI-Systempartition (FAT32, meist 100 bis 500 MB) eingehängt sein, bevor `grub-install` läuft. Bei BIOS wird auf die **ganze Platte** (z. B. `/dev/sda`) installiert, nicht auf eine Partition. Ein falsches Ziel überschreibt den Startbereich der falschen Platte. Prüfe es mit `lsblk`, bevor du den Befehl ausführst.

Läuft das System, aber ein Kernel-Update ist schiefgegangen: [Kernel, Boot und Initramfs](../02_Linux/16_Kernel_Boot_und_Initramfs.md).

## 4. Passwort vergessen oder zurücksetzen

### Windows (Passwort)

Zuerst die offiziellen Wege, sie ändern am wenigsten:

1. **Microsoft-Konto:** auf einem anderen Gerät `https://account.live.com/password/reset` öffnen und das Passwort zurücksetzen. Danach am Rechner mit dem neuen Passwort anmelden (Internetverbindung nötig).
2. **Lokales Konto mit Sicherheitsfragen:** Auf dem Anmeldebildschirm **Kennwort zurücksetzen** wählen und die Fragen beantworten.
3. **Anderes Administratorkonto vorhanden:** Dort anmelden und das Passwort ändern (als Administrator):

```powershell
$Passwort = Read-Host "Neues Passwort" -AsSecureString
Set-LocalUser -Name "BENUTZER" -Password $Passwort
```

Die Befehle stehen auch in [Benutzer und Rechteverwaltung](../01_Windows_11/05_Benutzer_und_Rechteverwaltung.md). Nicht getestet.

> **Hinweis:** Es gibt Tricks, die Anmeldung über eine Rettungsumgebung auszuhebeln (Austausch von Systemdateien). Sie sind hier nicht beschrieben: Sie beschädigen die Windows-Installation, verlieren das Daten-Verschlüsselungs-Passwort (EFS) und funktionieren bei BitLocker nicht. Ist das Konto verschlüsselt und kein Weg offen, bleibt nur: Daten sichern und neu installieren.

### Linux (Passwort)

Eigener Rechner, Festplatte **nicht verschlüsselt**:

1. Rechner starten und beim Start `Esc` (UEFI) bzw. `Shift` (BIOS) gedrückt halten, bis das GRUB-Menü erscheint.
2. **Advanced options for Ubuntu -> ... (recovery mode)** wählen.
3. Im Menü **root** (Root-Shell) auswählen, dann:

```bash
# Dateisystem beschreibbar einhängen
mount -o remount,rw /

# Passwort für den Benutzer neu setzen (BENUTZER ersetzen)
passwd BENUTZER

# Neu starten
reboot
```

Ist die Platte mit LUKS verschlüsselt, fragt schon der Start nach dem Festplattenpasswort. Das lässt sich nicht umgehen. Alternative von einem Live-Stick: [Chroot, Abschnitt 2.3](../04_Rettungsmedien_und_Live_Systeme/02_Chroot_Umgebungen.md). Nicht auf Rechnern ausführen, die dir nicht gehören.

## 5. Daten von einer defekten Platte retten

Die Regel: **Erst ein Abbild, dann arbeiten.** Mit `ddrescue` liest du so viel wie möglich, ohne die kaputte Platte unnötig zu belasten. Die vollständige Anleitung mit Mapfile und Wiederholungen steht in [Klonen und Imaging, Abschnitt 2](../03_Datenrettung_und_Forensik/01_Klonen_und_Imaging.md). Danach geht es mit [Dateiwiederherstellung](../03_Datenrettung_und_Forensik/02_Dateiwiederherstellung.md) (TestDisk, PhotoRec) weiter, aber nur auf dem Abbild.

Ablauf:

1. Rechner mit der defekten Platte **ausschalten**. Die Platte als **zweites** Laufwerk anschließen oder vom Live-Stick starten. Nicht vom kaputten Windows/Linux booten.
2. Eine **größere** Zielplatte bereithalten. Mit `lsblk` die Namen ermitteln. Nie raten.
3. Abbild ziehen (Kurzfassung, Details in der verlinkten Seite):

```bash
sudo apt install gddrescue
lsblk -o NAME,SIZE,MODEL,SERIAL
sudo ddrescue -n /dev/QUELLE /pfad/zum/abbild.img /pfad/zur/rettung.map
```

`-n` überspringt schwierige Bereiche zuerst. `QUELLE` ist die defekte Platte, **nicht** das Ziel. Vertauschte Angaben löschen die gesunde Platte. Danach mit derselben Mapfile in einem zweiten Durchgang (`-d -r3`) die Lücken schließen, siehe verlinkte Seite.

Danach am **Abbild** weiterarbeiten: Image einhängen und Dateien kopieren ([Klonen und Imaging, Abschnitt 3](../03_Datenrettung_und_Forensik/01_Klonen_und_Imaging.md)).

NTFS-Laufwerk (Windows), das nur noch "schmutzig" ist? Vom Linux-Live-Stick aus **erst auf dem Abbild** versuchen:

```bash
# Markierung "unsauber" zurücksetzen, repariert nur einfache Fehler (-n = nichts schreiben, nur testen)
sudo ntfsfix -n /dev/PARTITION
```

> **Warnung:** Ohne `-n` schreibt `ntfsfix`. Das gehört nur auf ein Abbild oder eine gesicherte Platte. `ntfsfix` ist kein Ersatz für `chkdsk` unter Windows.

Klackert die Platte laut oder ist sie nicht mehr erkennbar, bring sie zu einem Datenrettungsdienst. Weitere Versuche verschlechtern die Chancen.

## 6. SMART: Ist die Platte gesund?

SMART ist der Gesundheitsbericht jeder Festplatte und SSD.

### Linux (SMART)

```bash
sudo apt install smartmontools

# Laufwerke finden
lsblk -d -o NAME,SIZE,MODEL

# Kurzurteil (PASSED = ok)
sudo smartctl -H /dev/sda

# Alle Werte
sudo smartctl -a /dev/sda

# Kurztest starten, danach Ergebnis
sudo smartctl -t short /dev/sda
sudo smartctl -l selftest /dev/sda
```

Bei **NVMe-SSDs** heißt das Gerät `/dev/nvme0` (Laufwerk) bzw. `/dev/nvme0n1`:

```bash
sudo smartctl -a /dev/nvme0
```

Das Werkzeug erkennt den Typ meist selbst. Mit `-d nvme` lässt er sich erzwingen (in `smartctl --help` geprüft). Alle Optionen und Testarten: [SMART und Festplattendiagnose](../03_Datenrettung_und_Forensik/04_SMART_und_Festplattendiagnose.md).

Auf diese Werte achten:

| Wert | Warnsignal |
| --- | --- |
| `Reallocated_Sector_Ct` | Größer als 0 und steigend |
| `Current_Pending_Sector` | Größer als 0 |
| `Offline_Uncorrectable` | Größer als 0 |
| NVMe: `Percentage Used`, `Media and Data Integrity Errors` | Nahe 100 % bzw. größer als 0 |

Ein einzelner Wert ist kein Beweis, ein **Anstieg** schon. Sicherung zuerst, danach Austausch planen.

### Windows (SMART)

```powershell
# Gesundheitsstatus der Laufwerke
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus

# Detaillierte Zähler (Temperatur, Verschleiß, Fehler)
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object DeviceId, Temperature, Wear, ReadErrorsTotal, WriteErrorsTotal
```

Nicht getestet. Für eine grafische Anzeige bietet sich CrystalDiskInfo an (in der [winget-Liste](../11_Ersteinrichtung/programme.winget.json) enthalten).

## 7. Merkzettel zum Ausdrucken

1. Rechner aus, nicht herumprobieren.
2. Wichtige Daten zuerst sichern (Abbild), erst dann reparieren.
3. Zielgeräte immer mit `lsblk` bzw. `diskpart` prüfen, nie raten.
4. BitLocker-Schlüssel und Passwörter vorher sicher notieren.
5. Rettungsstick im Voraus vorbereiten, nicht erst im Notfall.

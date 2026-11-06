# 04 Download-Links: Installationsmedien, Rettungssysteme und portable Werkzeuge

Offizielle Quellen für alles, was man für Neuinstallation, Reparatur und Diagnose braucht. Die Links wurden am 2026-11-06 abgerufen. Die Seiten von Microsoft, Intel und HWiNFO blocken automatische Abrufe; sie sind im Browser zu prüfen.

> [!IMPORTANT]
> **Nach der Installation zuerst Windows aktualisieren:** [Update und Upgrade, Abschnitt 1](../01_Windows_11/01_Update_und_Upgrade.md). Danach Treiber und Software.

> [!WARNING]
> ISO-Dateien und Programme nur von der Seite des Herstellers laden. Nach dem Download die Prüfsumme vergleichen (Abschnitt 6). Beim Beschreiben eines USB-Sticks wird er **vollständig gelöscht**; vorher den richtigen Datenträger prüfen.

## 1. USB-Stick erstellen

| Werkzeug | Zweck | Link |
| --- | --- | --- |
| **Rufus** (Windows) | Ein ISO auf einen Stick schreiben, auch Windows 11 ohne TPM-Prüfung | <https://rufus.ie/de/> |
| **Ventoy** (Windows, Linux) | Einmal installieren, danach beliebig viele ISO-Dateien auf den Stick kopieren; siehe [01 Ventoy und ISOs](01_Ventoy_und_ISOs.md) | <https://www.ventoy.net/en/download.html> |
| **balenaEtcher** (Windows, Linux, macOS) | Einfaches Schreiben eines ISO, mit Überprüfung | <https://etcher.balena.io/> |

Für einen Stick mit mehreren Systemen ist Ventoy die beste Wahl. Für genau ein Windows-ISO reicht Rufus.

## 2. Windows

Gemeint ist die normale **64-Bit-Variante (x64)**, auch „x86-64“ oder „AMD64“ genannt. Sie läuft auf praktisch allen Desktop- und Laptop-PCs. Eine 32-Bit-Version (x86) gibt es für Windows 11 nicht, für Windows 10 nur noch über das Media Creation Tool.

| System | Link |
| --- | --- |
| Windows 11 (ISO, Installationsmedium, Installationsassistent) | <https://www.microsoft.com/de-de/software-download/windows11> |
| Windows 10 (Media Creation Tool) | <https://www.microsoft.com/de-de/software-download/windows10> |
| Windows 10 (ISO direkt) | <https://www.microsoft.com/de-de/software-download/windows10ISO> |
| Einzelne Updates und Treiber manuell laden | <https://www.catalog.update.microsoft.com/> |

- Auf der Windows-11-Seite den Bereich für das **ISO-Image** (Datenträgerabbild) wählen, die Ausführung für **x64-Geräte** und die Sprache *Deutsch* einstellen.
- Windows 10 erhält seit dem 14.10.2025 keine regulären Updates mehr. Neuinstallationen sollten, wenn die Hardware es zulässt, Windows 11 verwenden.
- Windows 11 verlangt TPM 2.0, Secure Boot und eine passende CPU. Rufus kann bei älterer Hardware diese Prüfungen im Auswahldialog abschalten. Das ist nicht von Microsoft unterstützt.

Anleitung für Stick und angepasste Installation: [08 ISO Erstellung und Custom OS](../01_Windows_11/08_ISO_Erstellung_und_Custom_OS.md).

## 3. Linux-Distributionen (ISO)

| Distribution | Für wen | Link |
| --- | --- | --- |
| Ubuntu | Einsteiger, Desktop und Server | <https://ubuntu.com/download/desktop> |
| Kubuntu | Ubuntu mit KDE Plasma | <https://kubuntu.org/getkubuntu/> |
| Debian | Stabil, Server | <https://www.debian.org/distrib/> |
| Linux Mint | Einsteiger, Windows-ähnlich | <https://linuxmint.com/download.php> |
| Fedora Workstation | Aktuelle Software | <https://fedoraproject.org/workstation/download> |
| openSUSE | Desktop und Server | <https://get.opensuse.org/> |
| Arch Linux | Fortgeschrittene | <https://archlinux.org/download/> |
| Bazzite | Gaming, unveränderliches System | <https://bazzite.gg/> |
| Tails | Anonym, läuft vom Stick | <https://tails.net/install/> |

Für Server und Rechner mit Dauerbetrieb die **LTS**-Variante von Ubuntu wählen.

## 4. Rettungs- und Reparatursysteme

| Werkzeug | Zweck | Link |
| --- | --- | --- |
| **Hiren's BootCD PE** | Windows-Reparaturumgebung (WinPE) mit Partitions-, Daten-, Passwort- und Diagnosewerkzeugen, bootet vom Stick | <https://www.hirensbootcd.org/download/> |
| **Medicat USB** | Großes Komplettpaket auf Ventoy-Basis mit Windows-Reparaturwerkzeugen, WinPE und Linux-Rettungssystemen; mehrere Gigabyte | <https://medicatusb.com/> |
| **SystemRescue** | Linux-Rettungssystem für Dateisysteme, Bootloader und Netzwerk | <https://www.system-rescue.org/Download/> |
| **Clonezilla** | Datenträger und Partitionen sichern und klonen | <https://clonezilla.org/downloads.php> |
| **GParted Live** | Partitionen verändern | <https://gparted.org/livecd.php> |
| **Memtest86+** | Arbeitsspeicher testen | <https://memtest.org/> |

- **Hiren's BootCD PE** und **Medicat** sind keine Microsoft-Produkte. Sie enthalten Programme von Drittanbietern. Nur von der verlinkten Projektseite laden und die Prüfsumme vergleichen.
- Die eingebaute Windows-Reparaturumgebung beschreibt [03 Windows RE](03_Windows_RE.md).

## 5. Sicherheits- und Pentesting-Systeme

> [!WARNING]
> Nur im eigenen Netz oder mit schriftlicher Erlaubnis des Eigentümers einsetzen.

| System | Hinweis | Link |
| --- | --- | --- |
| Kali Linux | Standard für Sicherheitstests, auch als Live-Stick | <https://www.kali.org/get-kali/> |
| Parrot Security | Alternative zu Kali, leichter | <https://parrotsec.org/download/> |
| Nmap | Netzwerk- und Portscanner | <https://nmap.org/download.html> |
| Wireshark | Netzwerkverkehr analysieren | <https://www.wireshark.org/download.html> |

Befehle zu `nmap`, `tcpdump` und `fail2ban`: [13 Tcpdump und Nmap](../02_Linux/13_Tcpdump_und_Nmap.md).

## 6. Prüfsumme kontrollieren

Auf der Download-Seite steht ein SHA-256-Wert. Er muss mit dem der heruntergeladenen Datei übereinstimmen:

```powershell
# Windows
Get-FileHash "$env:USERPROFILE\Downloads\DATEINAME.iso" -Algorithm SHA256
```

```bash
# Linux
sha256sum ~/Downloads/DATEINAME.iso
```

Weichen die Werte ab, die Datei löschen und neu laden.

## 7. Portable Werkzeuge für Diagnose und Ersteinrichtung

Portable Programme brauchen keine Installation. Sie lassen sich von einem USB-Stick oder einer Netzwerkfreigabe (zum Beispiel einer Synology) starten. Dazu die ZIP-Version laden, entpacken und die `.exe` ausführen.

| Werkzeug | Zweck | Link |
| --- | --- | --- |
| **Sysinternals Suite** | Prozesse, Autostart, Netzwerk, Datenträger (Process Explorer, Autoruns, TCPView, PsTools) | <https://learn.microsoft.com/de-de/sysinternals/downloads/sysinternals-suite> |
| **PortableApps.com** | Sammlung portabler Programme mit Startmenü | <https://portableapps.com/> |
| **NirSoft Utilities** | Kleine Einzelwerkzeuge, etwa für Netzwerk und Geräte | <https://www.nirsoft.net/> |
| **CrystalDiskInfo** | SMART-Zustand von Festplatten und SSDs | <https://crystalmark.info/en/software/crystaldiskinfo/> |
| **HWiNFO** | Hardware, Temperaturen und Sensoren | <https://www.hwinfo.com/download/> |
| **WinDirStat** | Belegten Speicherplatz sichtbar machen | <https://windirstat.net/> |
| **WizTree** | Sehr schnelle Platzanalyse | <https://diskanalyzer.com/> |
| **Everything** | Dateien sofort finden | <https://www.voidtools.com/> |
| **7-Zip** | Archive entpacken | <https://www.7-zip.org/> |
| **Notepad++** | Texteditor | <https://notepad-plus-plus.org/downloads/> |
| **PuTTY** | SSH-Verbindung unter Windows | <https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html> |
| **WinSCP** | Dateiübertragung per SFTP | <https://winscp.net/eng/download.php> |
| **Snappy Driver Installer Origin** | Treiber offline installieren | <https://www.snappy-driver-installer.org/> |
| **Ninite** | Gängige Programme in einem Schritt installieren | <https://ninite.com/> |

Für die Ersteinrichtung und den Fernzugriff gibt es in diesem Repository außerdem das [SSH-Toolkit](../toolkit/README.md) mit Start- und Stop-Skripten für Windows und Linux.

# Linux & Windows Befehlssammlung

Willkommen im ultimativen, strukturierten Nachschlagewerk für die Administration, Wartung und Datenrettung von Linux- und Windows-Systemen. 

---

## Inhaltsverzeichnis

### 🪟 01. Windows 11
- **[01 Update und Upgrade](01_Windows_11/01_Update_und_Upgrade.md)**
  PowerShell-Befehle (PSWindowsUpdate), Feature-Updates und Store-Updates erzwingen.
- **[02 Standardsoftware Deployment](01_Windows_11/02_Standardsoftware_Deployment.md)**
  Winget-Skripte (JSON), Silent Installs und Windows-Bloatware per Skript entfernen.
- **[03 Systemreparatur und Wartung](01_Windows_11/03_Systemreparatur_und_Wartung.md)**
  DISM, SFC-Scans, CHKDSK, Fsutil und automatisierte Bereinigung.
- **[04 Netzwerk und Reset](01_Windows_11/04_Netzwerk_und_Reset.md)**
  DNS-Flush, Winsock-Reset, WLAN-Diagnose und IP-Erneuerung.
- **[05 Benutzer und Rechteverwaltung](01_Windows_11/05_Benutzer_und_Rechteverwaltung.md)**
  PowerShell/CMD für lokale Nutzer, Gruppen, Domänen-Beitritt und NTFS-Besitz (takeown, icacls).
- **[06 AppX und Store Reparatur](01_Windows_11/06_AppX_und_Store_Reparatur.md)**
  Windows-Store Reset und PowerShell-Skripte zum Neu-Registrieren von Standard-Apps.

### 🐧 02. Linux (Kubuntu / Debian-Basis)
- **[01 Update und Bereinigung](02_Linux/01_Update_und_Bereinigung.md)**
  apt full-upgrade, Flatpak/Snap Update-Routinen, journalctl-Bereinigung und autoremove.
- **[02 Systemreparatur](02_Linux/02_Systemreparatur.md)**
  Abgebrochene dpkg-Konfigurationen abschließen, apt --fix-broken, Grub neu installieren und fsck/btrfs-Checks.
- **[03 Netzwerk und Dienste](02_Linux/03_Netzwerk_und_Dienste.md)**
  Systemd-Services steuern, Live-Logs lesen und UFW-Firewall Standardregeln.
- **[04 SSH und Remote-Zugriff](02_Linux/04_SSH_und_Remote_Zugriff.md)**
  SSH-Troubleshooting, Permission-Fixes und lokales/dynamisches Port-Forwarding.
- **[05 Speicher und Performance](02_Linux/05_Speicher_und_Performance.md)**
  Fehlerdiagnose bei vollen Festplatten (df, du, ncdu) und hängenden Systemen (htop, ps, kill).
- **[06 Benutzerverwaltung und Berechtigungen](02_Linux/06_Benutzerverwaltung.md)**
  Anlage von Nutzern, Sudoers-Pflege (visudo) und Rechtemanagement (chmod, chown).

### 🕵️ 03. Datenrettung und Forensik
- **[01 Klonen und Imaging](03_Datenrettung_und_Forensik/01_Klonen_und_Imaging.md)**
  Bitgenaue Kopien defekter Datenträger (dd, ddrescue) und Images via kpartx mounten.
- **[02 Dateiwiederherstellung](03_Datenrettung_und_Forensik/02_Dateiwiederherstellung.md)**
  Partitionstabellen reparieren (TestDisk) und gelöschte Rohdaten wiederherstellen (PhotoRec).
- **[03 Rechte und Besitz korrigieren](03_Datenrettung_und_Forensik/03_Rechte_und_Besitz_korrigieren.md)**
  Gesperrte Windows-Partitionen (Dirty Bit) per ntfsfix reparieren und alte Windows-Profile per takeown/icacls übernehmen.
- **[04 SMART und Festplattendiagnose](03_Datenrettung_und_Forensik/04_SMART_und_Festplattendiagnose.md)**
  Physikalische Laufwerksgesundheit mit `smartctl` prüfen, bevor Datenrettungs-Tools zum Einsatz kommen.

### 🚑 04. Rettungsmedien und Live-Systeme
- **[01 Ventoy und ISOs](04_Rettungsmedien_und_Live_Systeme/01_Ventoy_und_ISOs.md)**
  Installation und Pflege eines Ventoy-Sticks inkl. Liste der wichtigsten Admin-ISOs.
- **[02 Chroot Umgebungen (Linux)](04_Rettungsmedien_und_Live_Systeme/02_Chroot_Umgebungen.md)**
  Schritt-für-Schritt Anleitung, um aus einem Live-System in eine defekte Linux-Installation einzusteigen (mount --bind /dev, /proc, /sys).
- **[03 Windows RE (Recovery Environment)](04_Rettungsmedien_und_Live_Systeme/03_Windows_RE.md)**
  Bootrec, Bcdboot und Offline-SFC/DISM Reparaturen aus der blauen Windows-Kommandozeile.

---

> Die Sammlung wird laufend erweitert und gepflegt. Fokus liegt auf schnellen, effizienten Kommandozeilenbefehlen für den Notfall.

> **Hinweis:** Alle Dateien sind im Markdown-Format verfasst und optimiert für die Suche. Nutze die Suchfunktion (Strg+F / Cmd+F) in der jeweiligen Datei, um den passenden Befehl schnell zu finden.

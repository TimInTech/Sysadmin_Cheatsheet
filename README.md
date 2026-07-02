# Linux & Windows Befehlssammlung

Willkommen im ultimativen, strukturierten Nachschlagewerk für die Administration, Wartung und Datenrettung von Linux- und Windows-Systemen.

---

## Sicherheitshinweis

> **Warnung:** Viele Admin-, Recovery- und Reparaturbefehle in dieser Sammlung können Daten löschen, Systeme unbootbar machen oder Netzwerk-/Zugriffsregeln zurücksetzen.
> Vor Änderungen an Bootloader, BCD/GRUB, Dateisystemen, Partitionen, Firewall-Regeln, Benutzerrechten, Docker-Volumes oder Windows-Reparaturfunktionen immer zuerst Diagnose durchführen und ein Backup, Snapshot oder Image erstellen.
> Beispielgeräte wie `/dev/sda`, `/dev/sdb` oder Laufwerksbuchstaben aus der Windows-Recovery-Umgebung nie ungeprüft kopieren. Zielgeräte immer mit Diagnosebefehlen verifizieren.

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
- **[07 Registry Tweaks und Optimierung](01_Windows_11/07_Registry_Tweaks_und_Optimierung.md)**
  Registry-Backups, Explorer-/Taskleisten-Tweaks und vorsichtige Optimierung.
- **[08 ISO Erstellung und Custom OS](01_Windows_11/08_ISO_Erstellung_und_Custom_OS.md)**
  Windows-ISOs bereitstellen, Images bearbeiten und Installationsmedien vorbereiten.
- **[09 BitLocker und TPM](01_Windows_11/09_BitLocker_und_TPM.md)**
  BitLocker-Status, TPM-Pruefung, Recovery-Key-Absicherung und Wartungsfenster.

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
- **[07 Docker und Container](02_Linux/07_Docker_und_Container.md)**
  Ressourcen überwachen, in Container einsteigen und System bereinigen (Prune).
- **[08 Windows und macOS in Docker](02_Linux/08_Windows_macOS_Virtualisierung.md)**
  dockurr-VMs betreiben, sichern und wiederherstellen.
- **[09 systemd Timer und Journal](02_Linux/09_Systemd_Timer_und_Journal.md)**
  Wiederkehrende Jobs mit systemd-Timern, Logs und Journal-Aufbewahrung.
- **[10 Backup mit restic](02_Linux/10_Backup_mit_Restic.md)**
  Verschluesselte Backups, Integritaetspruefung, Restore-Test und Retention.
- **[11 nftables Firewall](02_Linux/11_Nftables_Firewall.md)**
  Host-Firewall mit Backup, Remote-Rollback, Syntaxcheck und Verifikation.
- **[12 TLS-Zertifikate und OpenSSL](02_Linux/12_TLS_Zertifikate_und_OpenSSL.md)**
  Zertifikate, Chains, CSRs, Private-Key-Schutz und sicherer Zertifikatstausch.

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

### 🖥️ 05. Proxmox VE
- **[01 Status, Versionen und Logs](05_Proxmox_VE/01_Status_Versionen_und_Logs.md)**
  Erstdiagnose mit `pveversion`, systemd, Journal, Storage, Clusterstatus und Gastübersicht.
- **[02 Virtuelle Maschinen mit qm](05_Proxmox_VE/02_VM_QM_Befehle.md)**
  VM-Status, Start/Shutdown, Snapshots, Rollback, Guest Agent und Konfigurationssicherung.
- **[03 LXC-Container mit pct](05_Proxmox_VE/03_LXC_PCT_Befehle.md)**
  Containerstatus, privilegiert/unprivilegiert, Start/Shutdown, Snapshots und Containerdiagnose.
- **[04 Storage, Backup und Restore](05_Proxmox_VE/04_Storage_Backup_und_Restore.md)**
  Storageprüfung, `vzdump`, Restore-Vorbereitung, `qmrestore`, `pct restore` und Verifikation.
- **[05 Netzwerk, Firewall und Cluster](05_Proxmox_VE/05_Netzwerk_Firewall_und_Cluster.md)**
  Bridges, Interfaces, Firewallstatus, Clusterstatus, Quorum-Hinweise und Rollback.

---

> Die Sammlung wird laufend erweitert und gepflegt. Fokus liegt auf schnellen, effizienten Kommandozeilenbefehlen für den Notfall.

> **Hinweis:** Alle Dateien sind im Markdown-Format verfasst und optimiert für die Suche. Nutze die Suchfunktion (Strg+F / Cmd+F) in der jeweiligen Datei, um den passenden Befehl schnell zu finden.

# 02 Linux (Kubuntu / Debian-Basis)

[Zur Startseite](../README.md)

- **[01 Update und Bereinigung](01_Update_und_Bereinigung.md)**
  apt full-upgrade, Flatpak/Snap Update-Routinen, journalctl-Bereinigung und autoremove.

- **[02 Systemreparatur](02_Systemreparatur.md)**
  Abgebrochene dpkg-Konfigurationen abschließen, apt --fix-broken, Grub neu installieren und fsck/btrfs-Checks.

- **[03 Netzwerk und Dienste](03_Netzwerk_und_Dienste.md)**
  Systemd-Services steuern, Live-Logs lesen und UFW-Firewall Standardregeln.

- **[04 SSH und Remote-Zugriff](04_SSH_und_Remote_Zugriff.md)**
  SSH-Troubleshooting, Permission-Fixes, Port-Forwarding und Server-Härtung (nur Schlüssel, kein Root-Login).

- **[05 Speicher und Performance](05_Speicher_und_Performance.md)**
  Fehlerdiagnose bei vollen Festplatten (df, du, ncdu) und hängenden Systemen (htop, ps, kill).

- **[06 Benutzerverwaltung und Berechtigungen](06_Benutzerverwaltung.md)**
  Anlage von Nutzern, Sudoers-Pflege (visudo) und Rechtemanagement (chmod, chown).

- **[07 Docker und Container](07_Docker_und_Container.md)**
  Ressourcen überwachen, in Container einsteigen und System bereinigen (Prune).

- **[08 Windows und macOS in Docker](08_Windows_macOS_Virtualisierung.md)**
  dockurr-VMs betreiben, sichern und wiederherstellen.

- **[09 systemd Timer und Journal](09_Systemd_Timer_und_Journal.md)**
  Wiederkehrende Jobs mit systemd-Timern, Logs und Journal-Aufbewahrung.

- **[10 Backup mit restic](10_Backup_mit_Restic.md)**
  Verschluesselte Backups, Integritaetspruefung, Restore-Test und Retention.

- **[11 nftables Firewall](11_Nftables_Firewall.md)**
  Host-Firewall mit Backup, Remote-Rollback, Syntaxcheck und Verifikation.

- **[12 TLS-Zertifikate und OpenSSL](12_TLS_Zertifikate_und_OpenSSL.md)**
  Zertifikate, Chains, CSRs, Private-Key-Schutz und sicherer Zertifikatstausch.

- **[13 tcpdump und nmap](13_Tcpdump_und_Nmap.md)**
  Paketmitschnitt (tcpdump), Netzwerkscans (nmap), BPF-Filter, NSE-Skripte und Diagnose-Workflows.

- **[14 Systeminformationen](14_Systeminformationen.md)**
  Distro, Kernel, Bootmodus, Architektur, Hardware und Zeit/Locale.

- **[15 APT Repository und Paketstatus](15_APT_Repository_und_Paketstatus.md)**
  Paketquellen, Keyrings, Upgrade-Simulation und Reparatur von Paketverwaltung.

- **[16 Kernel Boot und Initramfs](16_Kernel_Boot_und_Initramfs.md)**
  Kernel-Versionen, Bootmeldungen, Initramfs neu erzeugen und GRUB-Verifikation.

- **[17 AppArmor SELinux cgroupv2](17_AppArmor_SELinux_cgroupv2.md)**
  Sicherheitsprofile, LSM-Status und Container-Kompatibilitaet (cgroup v2).

- **[18 rsync](18_rsync.md)**
  Dateisynchronisation mit Dry-Run, Backup und Warnung vor --delete.

- **[19 BorgBackup](19_BorgBackup.md)**
  Deduplizierende Backups mit Borg: Init, Create, Check, Extract und Prune.

- **[20 Fail2ban](20_Fail2ban.md)**
  Brute-Force-Schutz: Status, Jails, Logs und Entsperren.

- **[21 Audit Logs](21_Audit_Logs.md)**
  Auth-, Sudo-, Auditd- und Login-Logs auswerten, SUID-Dateien prüfen.

- **[22 Secret Hygiene](22_Secret_Hygiene.md)**
  Shell-History, Git-Grep nach Secrets und .env-Dateien absichern.

- **[23 DNS-Diagnose](23_DNS_Diagnose.md)**
  Resolverstatus, systemd-resolved, dig, getent hosts und DNS-Server-Test.

- **[24 Pi-Hole und Unbound](24_PiHole_und_Unbound.md)**
  Pi-Hole Status/Logs, Unbound-Diagnose, Client-DNS und Split-DNS.

- **[25 NetworkManager und Netplan](25_NetworkManager_und_Netplan.md)**
  Netzwerkstack erkennen (NetworkManager/systemd-networkd) und Netplan pruefen.

- **[26 DHCP mDNS Avahi](26_DHCP_mDNS_Avahi.md)**
  DHCP-Leases, mDNS-Diensterkennung und Avahi-Status.

- **[27 Ubuntu 26.04 Neuerungen und Anwendungen](27_Ubuntu_26-04_Neuerungen_und_Anwendungen.md)**
  sudo-rs, uutils, APT 3 mit deb822-Quellen, Snap/Flatpak, Sicherheitswerkzeuge, Anwendungsübersicht sowie Docker und KVM.

- **[28 Ubuntu 26.04 Tastatur-Shortcuts](28_Ubuntu_26-04_Tastatur_Shortcuts.md)**
  GNOME-, Plasma- und Bash-Tastenkürzel.

- **[29 Tastaturbelegung DE und UK](29_Tastaturbelegung_DE_UK.md)**
  QWERTZ/QWERTY-Unterschiede, AltGr-Zeichen und Layout-Umschaltung unter Linux.

- **[30 Monitoring und Healthchecks](30_Monitoring_und_Healthchecks.md)**
  Schneller Systemüberblick, tägliches Prüfskript mit systemd-Timer, optionale Meldung über Healthchecks.io und Prometheus Node Exporter.

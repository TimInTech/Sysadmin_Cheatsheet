# Sysadmin Cheatsheet

<div align="center">

**Befehle und Anleitungen für Windows, Linux und Netzwerk.** Kurz erklärt, mit Warnungen vor gefährlichen Schritten.

[SSH-Zugang einrichten](toolkit/README.md) &nbsp;|&nbsp; [Notfall-Spickzettel](14_Reparatur_Spickzettel/01_Notfall_Spickzettel.md) &nbsp;|&nbsp; [ZIP herunterladen](https://github.com/TimInTech/Sysadmin_Cheatsheet/archive/refs/heads/main.zip)

</div>

> [!IMPORTANT]
> **Windows neu installiert?** Zuerst alle Updates und Treiber holen: [Windows komplett aktualisieren](01_Windows_11/01_Update_und_Upgrade.md#1-nach-der-neuinstallation-alles-in-einem-durchlauf). Danach die [Ersteinrichtung](11_Ersteinrichtung/01_Checkliste_Windows_und_Ubuntu.md). Installationsmedien und Rettungswerkzeuge: [Download-Links](04_Rettungsmedien_und_Live_Systeme/04_Download_Links.md).

## Themen

<table>
<tr><td width="33%" valign="top"><a href="01_Windows_11/README.md"><img src="assets/icons/windows.svg" width="40" height="40" alt=""><br><b>Windows 10 und 11</b></a><br><sub>Updates, Software, Reparatur, Netzwerk und Rechte.</sub></td><td width="33%" valign="top"><a href="02_Linux/README.md"><img src="assets/icons/linux.svg" width="40" height="40" alt=""><br><b>Linux</b></a><br><sub>Ubuntu und Debian: Updates, Dienste, Backup, Netzwerk.</sub></td><td width="33%" valign="top"><a href="03_Datenrettung_und_Forensik/README.md"><img src="assets/icons/datenrettung.svg" width="40" height="40" alt=""><br><b>Datenrettung</b></a><br><sub>Abbilder, Wiederherstellung, SMART und Rechte.</sub></td></tr>
<tr><td width="33%" valign="top"><a href="04_Rettungsmedien_und_Live_Systeme/README.md"><img src="assets/icons/rettung.svg" width="40" height="40" alt=""><br><b>Rettungsmedien</b></a><br><sub>Ventoy, Live-Systeme, Windows RE und Downloads.</sub></td><td width="33%" valign="top"><a href="14_Reparatur_Spickzettel/README.md"><img src="assets/icons/reparatur.svg" width="40" height="40" alt=""><br><b>Notfall-Spickzettel</b></a><br><sub>Startet nicht? Passwort weg? Platte defekt?</sub></td><td width="33%" valign="top"><a href="11_Ersteinrichtung/README.md"><img src="assets/icons/ersteinrichtung.svg" width="40" height="40" alt=""><br><b>Ersteinrichtung</b></a><br><sub>Checkliste nach der Neuinstallation und Programmpaket.</sub></td></tr>
<tr><td width="33%" valign="top"><a href="toolkit/README.md"><img src="assets/icons/toolkit.svg" width="40" height="40" alt=""><br><b>SSH-Toolkit</b></a><br><sub>Fernzugriff einrichten, auch ohne IT-Wissen.</sub></td><td width="33%" valign="top"><a href="13_Remotezugriff/README.md"><img src="assets/icons/remote.svg" width="40" height="40" alt=""><br><b>Remotezugriff</b></a><br><sub>RDP, VNC, Tailscale, WireGuard, Wake-on-LAN.</sub></td><td width="33%" valign="top"><a href="12_NAS_und_Netzwerkfreigaben/README.md"><img src="assets/icons/nas.svg" width="40" height="40" alt=""><br><b>NAS und Freigaben</b></a><br><sub>SMB, NFS, Synology und Tools vom NAS.</sub></td></tr>
<tr><td width="33%" valign="top"><a href="10_Android/README.md"><img src="assets/icons/android.svg" width="40" height="40" alt=""><br><b>Android</b></a><br><sub>adb und scrcpy: Handy am Computer.</sub></td><td width="33%" valign="top"><a href="15_Drucker_und_Scanner/README.md"><img src="assets/icons/drucker.svg" width="40" height="40" alt=""><br><b>Drucker und Scanner</b></a><br><sub>CUPS, SANE und Windows.</sub></td><td width="33%" valign="top"><a href="05_Proxmox_VE/README.md"><img src="assets/icons/proxmox.svg" width="40" height="40" alt=""><br><b>Proxmox VE</b></a><br><sub>VMs, Container, Storage, Backup.</sub></td></tr>
<tr><td width="33%" valign="top"><a href="06_Git_Repo_Hygiene/README.md"><img src="assets/icons/git.svg" width="40" height="40" alt=""><br><b>Git</b></a><br><sub>Repo-Hygiene, Secrets und Historie.</sub></td><td width="33%" valign="top"><a href="07_Webserver_Reverse_Proxy_TLS/README.md"><img src="assets/icons/webserver.svg" width="40" height="40" alt=""><br><b>Webserver und TLS</b></a><br><sub>Reverse Proxy, Zertifikate, Header.</sub></td><td width="33%" valign="top"><a href="08_Bazzite/README.md"><img src="assets/icons/bazzite.svg" width="40" height="40" alt=""><br><b>Bazzite</b></a><br><sub>Gaming-Linux: Updates, Btrfs, Diagnose.</sub></td></tr>
<tr><td width="33%" valign="top"><a href="09_KI_CLI_Slash-Befehle/README.md"><img src="assets/icons/ki.svg" width="40" height="40" alt=""><br><b>KI und CLI</b></a><br><sub>Slash-Befehle und freie KI ohne Konto.</sub></td></tr>
</table>

## Gut zu wissen

- **Einfache Sprache zuerst, Technik darunter.** Jede Seite beginnt mit einer kurzen Erklärung.
- **Nichts erfunden.** Befehle sind gegen Hilfe oder Dokumentation geprüft. Was nicht getestet ist, steht dabei.
- **Freie KI ohne Konto:** [Anleitung](09_KI_CLI_Slash-Befehle/00_Freie_KI_ohne_Konto.md).

## Sicherheitshinweis

> **Warnung:** Viele Admin-, Recovery- und Reparaturbefehle können Daten löschen, Systeme unbootbar machen oder Netzwerk- und Zugriffsregeln zurücksetzen. Vor Änderungen an Bootloader, Dateisystemen, Partitionen, Firewall-Regeln oder Benutzerrechten immer zuerst Diagnose durchführen und ein Backup oder Image erstellen. Geräte wie `/dev/sda` oder Laufwerksbuchstaben in der Windows-Wiederherstellung nie ungeprüft kopieren.

---

> Die Sammlung wird laufend erweitert. Fokus: schnelle, sichere Befehle für den Notfall.

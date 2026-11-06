# 27 Ubuntu 26.04 – Neuerungen, Paketquellen und Anwendungen (Linux)

Besonderheiten von Ubuntu 26.04 LTS („Resolute Raccoon“) gegenüber älteren Ubuntu-Versionen und Linux Mint, dazu Installationshinweise für gängige Software.

Stand: 2026-11 · Ubuntu 26.04.1 LTS, Kernel 7.x, APT 3.2, GNOME 50.

Quellen:

- Ubuntu Server Docs: <https://ubuntu.com/server/docs/>
- Ubuntu Packages: <https://packages.ubuntu.com/>
- Snap Store: <https://snapcraft.io/store>

> [!NOTE]
> Grundbefehle sind hier bewusst nicht wiederholt. Sie stehen in den vorhandenen Dateien: [Update und Bereinigung](01_Update_und_Bereinigung.md), [Netzwerk und Dienste](03_Netzwerk_und_Dienste.md) (inkl. UFW), [SSH](04_SSH_und_Remote_Zugriff.md), [Speicher und Performance](05_Speicher_und_Performance.md), [Benutzerverwaltung](06_Benutzerverwaltung.md), [Docker](07_Docker_und_Container.md), [APT-Status](15_APT_Repository_und_Paketstatus.md), [rsync](18_rsync.md), [Fail2ban](20_Fail2ban.md).

## 1. Was sich in 26.04 ändert

- **`sudo` ist `sudo-rs`** (Rust-Neuimplementierung, 0.2.x). Alltagsaufrufe wie `sudo apt …` und `sudo -i` funktionieren unverändert. Bei Sonderoptionen vorher `sudo --help` prüfen.
- **Coreutils sind uutils (Rust)**, 0.10.x. `ls`, `cp`, `mv`, `rm`, `du` verhalten sich im Normalfall wie gewohnt. Seltene GNU-Optionen können fehlen.
- **APT 3.x mit deb822-Quellen.** Quellen liegen in `/etc/apt/sources.list.d/*.sources`, die Hauptquelle in `ubuntu.sources`.
- **Firefox, Thunderbird und Chromium sind Snaps.** Die gleichnamigen APT-Pakete sind nur Übergangspakete, die den Snap installieren.
- **`dmesg` braucht `sudo`** (`kernel.dmesg_restrict=1`).
- **Wayland ist Standard.** X11-Werkzeuge wie `xdotool` und manche Screenshot-Tools funktionieren nur eingeschränkt.
- **Ersatz für entfallene Pakete:** `fastfetch` statt `neofetch`, `netcat-openbsd` statt `netcat`, `docker-compose-v2` statt `docker-compose`, `qemu-system-x86` statt `qemu-kvm`.
- **Netzwerkschnittstellen** heißen `enp3s0` oder `wlp2s0`, nicht `eth0`. Namen mit `ip -br a` ermitteln.
- **Nicht in Ubuntu enthalten:** Cinnamon, Mint-Update-Manager und die Timeshift-Vorinstallation von Linux Mint.

## 2. Paketquellen und Paketverwaltung

```bash
# Alte .list-Quellen ins deb822-Format umstellen
sudo apt modernize-sources

# Installierte und verfügbare Version samt Quelle anzeigen
apt policy PAKET

# PPA hinzufügen (Paket software-properties-common), danach Listen aktualisieren
sudo add-apt-repository ppa:NAME/PPA
sudo apt update

# Proprietäre Treiber prüfen und installieren
ubuntu-drivers devices
sudo ubuntu-drivers install

# Auf die nächste Ubuntu-Version wechseln (nur nach Backup)
sudo do-release-upgrade
```

> [!WARNING]
> PPAs sind Drittquellen. Nur aus vertrauenswürdiger Hand verwenden und nicht dauerhaft für Systempakete einsetzen. `-y` überspringt die Rückfrage: bei `autoremove`, `purge` und `full-upgrade` zuerst ohne `-y` lesen, was entfernt wird. Vor `do-release-upgrade` ein Backup oder einen Snapshot anlegen.

### Snap

| Befehl | Zweck |
|---|---|
| `sudo snap install NAME` | Installieren (`--classic` nur, wenn der Snap es verlangt) |
| `snap list` | Installierte Snaps |
| `snap info NAME` | Kanäle und Versionen |
| `sudo snap refresh` | Alle aktualisieren |
| `sudo snap remove NAME` | Entfernen |

### Flatpak

Flatpak ist installiert, Flathub muss einmalig als Quelle angelegt werden.

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.example.AppName   # Benutzerinstallation: --user
flatpak run org.example.AppName
flatpak uninstall org.example.AppName
```

## 3. Sicherheit

| Werkzeug | Einrichtung | Hinweis |
|---|---|---|
| `ufw` | `sudo ufw allow 22/tcp` → `sudo ufw enable` → `sudo ufw status verbose` | Paket vorhanden, standardmäßig **inaktiv**. Erst SSH erlauben, dann aktivieren, sonst sperrt man sich bei Remote-Zugriff aus. Details: [Netzwerk und Dienste](03_Netzwerk_und_Dienste.md). |
| `unattended-upgrades` | `sudo dpkg-reconfigure --priority=low unattended-upgrades` | Automatische Sicherheitsupdates, in Ubuntu meist schon aktiv. |
| `lynis` | `sudo lynis audit system` | Auditbericht, ersetzt keine Härtung. |
| `clamav` | `sudo freshclam` · `clamscan -r /home` | `clamtk` ist die GUI. Der Dienst `clamav-freshclam` kann `freshclam` blockieren: dann erst stoppen. |
| `fail2ban` | `sudo systemctl enable --now fail2ban` | Sinnvoll bei von außen erreichbarem SSH. Details: [Fail2ban](20_Fail2ban.md). |

## 4. Netzwerkwerkzeuge installieren

| Werkzeug | Zweck | Paket |
|---|---|---|
| `nmap` | Port- und Hostscan | `nmap` |
| `traceroute` | Route zum Ziel | `traceroute` |
| `iperf3` | Bandbreite messen (Server `iperf3 -s`, Client `iperf3 -c SERVERIP`) | `iperf3` |
| `arp-scan` | Geräte im LAN (`sudo arp-scan --localnet`) | `arp-scan` |
| `nc` | Verbindungen testen (`nc -zv host 22`) | `netcat-openbsd` |
| `iftop` | Bandbreite je Verbindung (`sudo iftop -i SCHNITTSTELLE`) | `iftop` |
| `wireshark` | Paketanalyse (GUI) | `wireshark` |
| `ssh`-Server | Fernzugriff auf diesen Rechner | `openssh-server` |

- Wireshark nicht mit `sudo` starten. Stattdessen `sudo dpkg-reconfigure wireshark-common` (Capture für Nicht-Root erlauben), Benutzer mit `sudo usermod -aG wireshark $USER` hinzufügen und neu anmelden.
- Scans (`nmap`, `arp-scan`) nur im eigenen oder ausdrücklich freigegebenen Netz. Mitschnitte mit `tcpdump`: [Tcpdump und Nmap](13_Tcpdump_und_Nmap.md).

## 5. Anwendungen

Installation: `sudo apt install PAKET` oder `sudo snap install PAKET`.

Terminal-Werkzeuge (APT): `htop`, `ncdu`, `git`, `unzip`, `build-essential`, `tmux`, `screen`, `rsync`, `xrdp` (Fernzugriff per RDP), `fastfetch`. `net-tools` nur für Altbefehle wie `ifconfig`.

| Bereich | Aus dem Archiv (APT) | Als Snap | Nicht im Archiv |
|---|---|---|---|
| Browser | `firefox`, `chromium-browser` (installieren jeweils den Snap) | – | `vivaldi`, `brave-browser`, `opera` (Herstellerquelle nötig) |
| Büro und PDF | `libreoffice`, `thunderbird`, `okular`, `xournalpp`, `keepassxc` | `bitwarden` | `foxit-reader` |
| Grafik und Foto | `gimp`, `inkscape`, `krita`, `darktable`, `shotwell`, `kolourpaint`, `blender` | – | `qview` |
| Audio und Video | `vlc`, `audacity`, `kdenlive`, `handbrake`, `simplescreenrecorder` | `obs-studio`, `shotcut`, `spotify` | `cheese`, `openshot` |
| Kommunikation | `remmina`, `filezilla` | `telegram-desktop`, `slack --classic`, `discord` | `teamviewer` (Herstellerpaket) |
| Entwicklung | `build-essential`, `git` | `code --classic`, `postman` | – |
| Sonstiges | `steam-installer`, `qbittorrent`, `bleachbit` | – | `balena-etcher` (Herstellerpaket oder AppImage) |
| Virtualisierung | `virtualbox`, `virt-manager` | – | – |

Steam: Das Paket heißt `steam-installer` und braucht i386-Architektur und Multiverse. Die Installationsabfrage zeigt die Details.

## 6. Docker und KVM installieren

```bash
# Docker aus dem Ubuntu-Archiv (kein Paket von Docker Inc.)
sudo apt install docker.io docker-compose-v2
sudo systemctl enable --now docker
sudo usermod -aG docker $USER   # danach neu anmelden
docker compose up -d            # nicht mehr "docker-compose"

# KVM/QEMU mit virt-manager
sudo apt install qemu-system-x86 libvirt-daemon-system virt-manager
sudo usermod -aG libvirt,kvm $USER   # danach neu anmelden
lscpu | grep -i virtualization       # Hardwarevirtualisierung aktiv?
```

> [!WARNING]
> Mitglieder der Gruppe `docker` haben praktisch Root-Rechte. Auf Mehrbenutzer-Systemen bewusst entscheiden. Betrieb und Aufräumen von Containern: [Docker und Container](07_Docker_und_Container.md).

Tastenkürzel: [Ubuntu 26.04 Tastatur-Shortcuts](28_Ubuntu_26-04_Tastatur_Shortcuts.md).

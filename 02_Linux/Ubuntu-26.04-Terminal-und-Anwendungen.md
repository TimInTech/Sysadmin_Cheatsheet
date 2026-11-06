# Ubuntu 26.04 – Terminal-Befehle und Anwendungen

Stand: 2026-11-01 · Ubuntu 26.04.1 LTS (Resolute Raccoon), Kernel 7.x, APT 3.2, GNOME 50.
← [[60_Notizen/Lernen/Lernnotizen|Lernnotizen]] · Verwandt: [[Ubuntu-26.04-Tastatur-Shortcuts]] · [[20_Systeme/Installations-Merkliste|Installations-Merkliste]]

Überarbeitung einer Linux-Mint-Referenz. Paketnamen, Verfügbarkeit und Versionen wurden auf diesem Rechner mit `apt-cache policy` und `snap info` geprüft. Befehle selbst wurden nicht erneut ausgeführt; alles Zerstörerische ist als solches markiert.

## Was sich in 26.04 gegenüber Mint und älteren Ubuntu-Versionen ändert

- **`sudo` ist `sudo-rs`** (hier 0.2.13). Alltagsaufrufe wie `sudo apt …` und `sudo -i` funktionieren; bei Sonderoptionen die Hilfe mit `sudo --help` prüfen.
- **Coreutils sind uutils (Rust)**, hier 0.10 (`ls --version`). `ls`, `cp`, `mv`, `rm`, `du` verhalten sich im Normalfall gleich; seltene GNU-Optionen können fehlen.
- **APT 3.x mit deb822-Quellen.** Quellen liegen in `/etc/apt/sources.list.d/*.sources`, die Hauptquelle in `ubuntu.sources`. Alte `*.list`-Dateien mit `sudo apt modernize-sources` umstellen.
- **Firefox, Thunderbird und Chromium sind Snaps.** Die Pakete `firefox`, `thunderbird`, `chromium-browser` sind nur Übergangspakete, die den Snap installieren.
- **`dmesg` braucht `sudo`** (`kernel.dmesg_restrict=1`).
- **Wayland ist Standard**, Fenster- und Bildschirmwerkzeuge für X11 (zum Beispiel `xdotool`, manche Screenshot-Tools) funktionieren eingeschränkt.
- **Mint-Eigenheiten entfallen:** Cinnamon, Mint-Update-Manager und Timeshift-Standardinstallation gehören nicht zu Ubuntu.

## 1. Grundlagen und Dateisystem

| Befehl | Zweck | Beispiel |
|---|---|---|
| `pwd` | Aktuelles Verzeichnis | `pwd` |
| `ls` | Verzeichnisinhalt | `ls -la` |
| `cd` | Verzeichnis wechseln | `cd /pfad/zum/verzeichnis` |
| `cat` | Datei ausgeben | `cat datei.txt` |
| `less` | Datei seitenweise lesen (`q` beendet) | `less datei.txt` |
| `mkdir` | Verzeichnis anlegen | `mkdir -p a/b/c` |
| `cp` | Kopieren | `cp quelle.txt ziel.txt` · `cp -r ordner1 ordner2` |
| `mv` | Verschieben / umbenennen | `mv alt.txt neu.txt` |
| `touch` | Leere Datei / Zeitstempel | `touch datei.txt` |
| `ln -s` | Symbolischer Link | `ln -s /ziel /linkname` |
| `find` | Dateien suchen | `find / -name "dateiname" 2>/dev/null` |
| `du` | Platzbedarf | `du -sh ordner/` |
| `df` | Belegung der Dateisysteme | `df -h` |
| `lsblk` | Blockgeräte und Partitionen | `lsblk -f` |
| `grep` | Textmuster suchen | `grep -rn "suchtext" ordner/` |
| `sed` | Text ersetzen | `sed 's/alt/neu/g' datei.txt` |
| `awk` | Spalten verarbeiten | `awk '{print $1}' datei.txt` |
| `chmod` | Rechte ändern | `chmod 755 datei` · `chmod -R 755 verzeichnis/` |
| `chown` | Besitzer ändern | `sudo chown benutzer:gruppe datei` |
| `mount` / `umount` | Dateisystem ein-/aushängen | `sudo mount /dev/DEVICE /mnt` · `sudo umount /mnt` |

`ln -s` hat die Reihenfolge **Ziel, dann Linkname**. Die Altfassung nannte `/quelle /ziel`, was leicht zu vertauschen ist.

> [!warning] Zerstörerisch
> `rm datei.txt` und `rm -r verzeichnis` löschen endgültig, ohne Papierkorb. Mit `sudo` besonders gefährlich. Vorher mit `ls` prüfen, was das Muster trifft. Für den Papierkorb: `gio trash datei`.

`mount /dev/DEVICE`: Gerätenamen vorher mit `lsblk` ermitteln, nie raten.

## 2. Prozesse, Benutzer und Dienste

| Befehl | Zweck | Beispiel |
|---|---|---|
| `ps` | Prozessliste | `ps aux` |
| `top` / `htop` | Laufende Last, interaktiv | `htop` |
| `kill` | Prozess beenden (SIGTERM) | `kill PID` |
| `kill -9` | Erzwingen (SIGKILL), ohne Aufräumen | `kill -9 PID` |
| `pkill` | Nach Name beenden | `pkill -f prozessname` |
| `adduser` / `deluser` | Benutzer anlegen / entfernen | `sudo adduser name` · `sudo deluser name` |
| `usermod` | Gruppen ändern | `sudo usermod -aG sudo name` |
| `passwd` | Passwort ändern | `sudo passwd name` |
| `last` | Letzte Anmeldungen | `last name` |
| `systemctl` | Dienste | `sudo systemctl enable --now dienst` · `systemctl status dienst` |
| `journalctl` | Dienstprotokolle | `journalctl -u dienst -b` |
| `rsync` | Synchronisieren | `rsync -avz quelle/ ziel/` |
| `tmux` / `screen` | Sitzungen im Hintergrund | `tmux new -s name` · `tmux attach -t name` · `screen -S name` · `screen -r name` |

`kill -9` nur als letztes Mittel: Der Prozess kann nichts mehr speichern. `usermod -aG` nie ohne `-a`, sonst werden alle anderen Gruppen ersetzt.

> [!warning] Zerstörerisch
> `rsync … --delete` löscht im Ziel alles, was in der Quelle fehlt. Erst mit `--dry-run` testen. Der abschließende Schrägstrich bei `quelle/` entscheidet, ob der Ordner selbst oder sein Inhalt kopiert wird.

## 3. Netzwerk

| Befehl | Zweck | Beispiel | Paket |
|---|---|---|---|
| `ip` | Adressen und Routen (ersetzt `ifconfig`) | `ip -br a` · `ip r` | vorhanden |
| `ping` | Erreichbarkeit | `ping -c 4 host` | vorhanden |
| `curl` | HTTP-Anfragen | `curl -I https://example.com` · `curl -O https://example.com/datei.zip` | vorhanden |
| `wget` | Download | `wget https://example.com/datei.zip` | vorhanden |
| `ss` | Offene Ports und Verbindungen (ersetzt `netstat`) | `ss -tulpn` | vorhanden |
| `nmcli` | NetworkManager | `nmcli dev wifi list` · `nmcli con up id "NAME"` | vorhanden |
| `ssh` | Remote-Shell | `ssh benutzer@host` · `ssh -p 2222 benutzer@host` | `openssh-client` |
| `scp` | Kopieren über SSH | `scp datei benutzer@host:/pfad/` | `openssh-client` |
| `nmap` | Port- und Hostscan | `nmap -p 22,80,443 HOSTOBERNETZ` | `nmap` |
| `traceroute` | Route zum Ziel | `traceroute host` | `traceroute` |
| `iperf3` | Bandbreite messen | Server `iperf3 -s`, Client `iperf3 -c SERVERIP` | `iperf3` |
| `arp-scan` | Geräte im LAN | `sudo arp-scan --localnet` | `arp-scan` |
| `nc` | Verbindungen testen | `nc -zv host 22` | `netcat-openbsd` |
| `tcpdump` | Pakete mitschneiden | `sudo tcpdump -i SCHNITTSTELLE -w capture.pcap` | `tcpdump` |
| `iftop` | Bandbreite je Verbindung | `sudo iftop -i SCHNITTSTELLE` | `iftop` |
| `wireshark` | Paketanalyse (GUI) | siehe unten | `wireshark` |

- Schnittstellennamen heißen unter Ubuntu nicht mehr `eth0`, sondern zum Beispiel `enp3s0` oder `wlp2s0`. Mit `ip -br a` ermitteln.
- Das Paket `netcat` existiert in 26.04 nicht; installiert wird `netcat-openbsd`.
- SSH-Server auf einem Rechner: `sudo apt install openssh-server`.
- Wireshark nicht mit `sudo` starten. Stattdessen `sudo dpkg-reconfigure wireshark-common` (Capture für Nicht-Root erlauben), Benutzer mit `sudo usermod -aG wireshark $USER` hinzufügen und neu anmelden.
- Scans (`nmap`, `arp-scan`) nur im eigenen oder ausdrücklich freigegebenen Netz.

## 4. Paketverwaltung

### APT

| Befehl | Zweck |
|---|---|
| `sudo apt update` | Paketlisten aktualisieren |
| `sudo apt upgrade` | Installierte Pakete aktualisieren |
| `sudo apt full-upgrade` | Aktualisieren inklusive Abhängigkeitsänderungen und Entfernungen |
| `sudo apt install PAKET` | Installieren |
| `sudo apt remove PAKET` | Entfernen, Konfiguration bleibt |
| `sudo apt purge PAKET` | Entfernen inklusive Konfiguration |
| `apt search BEGRIFF` | Suchen |
| `apt show PAKET` | Details |
| `apt policy PAKET` | Installierte und verfügbare Version, Quelle |
| `sudo apt autoremove` | Nicht mehr benötigte Abhängigkeiten entfernen |
| `sudo apt clean` / `sudo apt autoclean` | Paket-Cache leeren / veraltete Einträge löschen |
| `sudo apt --fix-broken install` | Beschädigte Abhängigkeiten reparieren |
| `sudo dpkg --configure -a` | Unterbrochene Konfiguration abschließen |
| `sudo apt modernize-sources` | Alte `.list`-Quellen ins deb822-Format umstellen |
| `sudo add-apt-repository ppa:NAME/PPA` | PPA hinzufügen (`software-properties-common`), danach `sudo apt update` |

`-y` überspringt die Rückfrage; bei `autoremove`, `purge` und `full-upgrade` zuerst ohne `-y` lesen, was entfernt wird. PPAs sind Drittquellen, nur aus vertrauenswürdiger Hand und nie als Dauerlösung für Systempakete.

### Snap

| Befehl | Zweck |
|---|---|
| `sudo snap install NAME` | Installieren (`--classic` nur, wenn der Snap es verlangt) |
| `snap list` | Installierte Snaps |
| `sudo snap refresh` | Alle aktualisieren |
| `sudo snap remove NAME` | Entfernen |

### Flatpak

Flatpak 1.16 ist installiert, die Discover-Anbindung (`plasma-discover-backend-flatpak`) ist im Archiv vorhanden. Flathub muss einmalig als Quelle angelegt sein.

| Befehl | Zweck |
|---|---|
| `flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo` | Flathub einrichten |
| `flatpak install flathub org.example.AppName` | Installieren (ohne `sudo` als Benutzerinstallation mit `--user`) |
| `flatpak run org.example.AppName` | Starten |
| `flatpak uninstall org.example.AppName` | Entfernen |

## 5. Wartung und Reparatur

| Befehl | Zweck | Hinweis |
|---|---|---|
| `sudo fsck /dev/DEVICE` | Dateisystem prüfen | nur ungemountet, vorher Backup |
| `sudo update-grub` | GRUB-Konfiguration neu erzeugen | |
| `sudo journalctl --vacuum-time=2weeks` | Alte Logs löschen | endgültig |
| `sudo dmesg \| less` | Kernelmeldungen | `sudo` nötig |
| `sudo lshw -short` | Hardwareübersicht | |
| `sudo smartctl -a /dev/DEVICE` | SMART-Status | Paket `smartmontools`; bei NVMe `/dev/nvme0` |
| `sudo parted /dev/DEVICE` | Partitionen | `print` zeigt nur an |

> [!warning] Zerstörerisch
> `parted` mit `mkpart`, `rm`, `resize` und `fsck` auf einem falschen Gerät können Daten zerstören. Vor dem Eingriff Backup oder Snapshot, Gerät doppelt mit `lsblk` prüfen. Auf dieser Maschine hat die NVMe-Diagnose gezeigt, dass SMART nur ein Indiz ist, kein Beweis: [[20_Systeme/Kubuntu/Kubuntu NVMe-Ausfall Fanxiang S501Q 2026-08-04|NVMe-Ausfall 2026-08-04]].

## 6. Sicherheit

| Werkzeug | Einrichtung | Hinweis |
|---|---|---|
| `ufw` | `sudo ufw allow 22/tcp` → `sudo ufw enable` → `sudo ufw status verbose` | Paket ist vorhanden, aber standardmäßig **inaktiv**. Erst SSH erlauben, dann aktivieren, sonst sperrt man sich bei Remote-Zugriff aus. |
| `unattended-upgrades` | `sudo dpkg-reconfigure --priority=low unattended-upgrades` | Automatische Sicherheitsupdates, in Ubuntu meist schon aktiv. |
| `lynis` | `sudo lynis audit system` | Auditbericht, ersetzt keine Härtung. |
| `clamav` | `sudo freshclam` · `clamscan -r /home` | `clamtk` ist die GUI. Der Dienst `clamav-freshclam` kann `freshclam` blockieren: dann erst stoppen. |
| `fail2ban` | `sudo systemctl enable --now fail2ban` | Sinnvoll nur bei von außen erreichbarem SSH; eigene Regeln unter `/etc/fail2ban/jail.d/`. |

## 7. Anwendungen

### Terminal-Werkzeuge (APT)

`htop`, `ncdu`, `git`, `unzip`, `build-essential`, `net-tools` (nur für Altbefehle wie `ifconfig`), `tmux`, `screen`, `rsync`, `xrdp` (Fernzugriff per RDP), **`fastfetch`** statt `neofetch`.

`neofetch` gibt es in 26.04 nicht mehr; `fastfetch` ist der Ersatz.

### Grafische Anwendungen

Installation: `sudo apt install PAKET` oder `sudo snap install PAKET`.

| Bereich | Aus dem Archiv (APT) | Als Snap | Nicht in Ubuntu 26.04 |
|---|---|---|---|
| Browser | `firefox`, `chromium-browser` (installieren jeweils den Snap) | – | `vivaldi`, `brave-browser`, `opera` (Herstellerquelle nötig) |
| Büro und PDF | `libreoffice`, `thunderbird`, `okular`, `xournalpp`, `keepassxc` | `bitwarden` | `foxit-reader` (Snap nicht gefunden) |
| Grafik und Foto | `gimp`, `inkscape`, `krita`, `darktable`, `shotwell`, `kolourpaint`, `blender` | – | `qview` |
| Audio und Video | `vlc`, `audacity`, `kdenlive`, `handbrake`, `simplescreenrecorder` | `obs-studio`, `shotcut`, `spotify` | `cheese`, `openshot` (nicht als Paket) |
| Kommunikation | `remmina`, `filezilla` | `telegram-desktop`, `slack --classic`, `discord`, `zoom-client` (inoffiziell), `whatsdesk` (inoffizieller WhatsApp-Client) | `jitsi-meet`-Snap (nicht gefunden), `teamviewer` (Herstellerpaket) |
| Entwicklung | `build-essential`, `git` | `code --classic`, `postman` | – |
| Spiele und Sonstiges | `steam-installer`, `qbittorrent`, `bleachbit` | – | `balena-etcher` (Herstellerpaket oder AppImage) |
| Virtualisierung | `virtualbox` (7.2), `virt-manager` | – | – |

Steam: Das Paket heißt `steam-installer` und benötigt i386-Architektur und Multiverse; Details zeigt die Installationsabfrage.

### Netzwerk (zusätzlich)

`zenmap` (Nmap-GUI), `etherape` (Verkehrsgrafik) per APT. Angry IP Scanner nur von der Herstellerseite; LanScan wird in der Altfassung als Flatpak genannt und wurde nicht geprüft.

## 8. Virtualisierung und Container

### Docker

```bash
sudo apt install docker.io docker-compose-v2
sudo systemctl enable --now docker
sudo usermod -aG docker $USER   # danach neu anmelden
docker run -d -p 80:80 --name webserver nginx
docker compose up -d            # nicht mehr "docker-compose"
```

- `docker-compose` (v1) existiert in 26.04 nicht; `docker-compose-v2` liefert `docker compose`.
- Mitglieder der Gruppe `docker` haben praktisch Root-Rechte. Auf Mehrbenutzer-Systemen bewusst entscheiden.
- Docker (`docker.io` 29.x) ist ein Archivpaket und kein Herstellerpaket von Docker Inc.

### KVM/QEMU

```bash
sudo apt install qemu-system-x86 libvirt-daemon-system virt-manager
sudo usermod -aG libvirt,kvm $USER   # danach neu anmelden
```

`qemu-kvm` existiert als Paketname nicht mehr; `qemu-system-x86` ersetzt es. Prüfen, ob Hardwarevirtualisierung aktiv ist: `lscpu | grep -i virtualization`.

## Offene Punkte

- Befehle in Kapitel 3 bis 8 sind inhaltlich aus der Mint-Referenz übernommen und nur bei Paketnamen und Versionen gegen dieses System geprüft.
- Die Aussage zu `sudo-rs`-Sonderoptionen ist nicht im Einzelnen getestet.

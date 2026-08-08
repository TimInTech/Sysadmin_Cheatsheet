# 01 Grundlagen und Erste Schritte

## 1. Architektur in Kurzform

- **Bazzite:** Gaming-orientiertes Fedora-Atomic-Desktop-Image aus dem Universal-Blue-Projekt.
- **Fedora Atomic Desktop:** Image-basierte Desktop-Familie mit transaktionalen Deployments statt Paket-für-Paket-Upgrade des laufenden Systems.
- **Universal Blue:** Erstellt signierte, automatisiert gebaute OCI-Systemimages auf Fedora-Basis.
- **OCI-Image:** Transportformat des Betriebssystemabbilds. Das laufende System bootet aus einem versionierten Image.
- **OSTree/rpm-ostree:** Verwaltet Deployments, Rollbacks, Rebases, Kernelargumente und optional geschichtete RPM-Pakete.
- **bootc:** Moderne Verwaltung bootfähiger Containerimages. `bootc status` ergänzt die Diagnose; Bazzite-Updates erfolgen bevorzugt über `ujust update`.
- **Atomic Update:** Ein neues Deployment wird vollständig vorbereitet. Das laufende Root-Dateisystem wird nicht schrittweise umgebaut.
- **Flatpak:** Primärer Weg für grafische Anwendungen.
- **Homebrew:** Primärer Weg für CLI/TUI-Werkzeuge.
- **Distrobox:** Integrierte Linux-Container für klassische Paketmanager und Entwicklungsumgebungen.
- **Podman/Quadlet:** Rootless Container und deklarative systemd-Dienste.
- **systemd:** Dienst-, Session-, Boot- und Journalverwaltung wie auf Fedora.

### Bazzite gegenüber Fedora Workstation

| Thema | Bazzite | Fedora Workstation |
|---|---|---|
| Basis | Versioniertes OCI-Systemimage | Einzelne RPM-Pakete |
| Host-Installation | Flatpak/Brew/Container bevorzugt | `dnf` üblich |
| Update | Neues Deployment, Neustart | Laufendes Paket-Upgrade |
| Rollback | Vorheriges bootbares Deployment | Nicht systemweit eingebaut |
| `/usr` | Read-only aus Image | Normal beschreibbar |
| `/etc`, `/var`, Home | Persistente lokale Daten | Persistente lokale Daten |

## 2. Host oder Container erkennen

```bash
cat /run/.containerenv 2>/dev/null || echo "Host-Kontext"
test -f /run/.toolboxenv && echo "Toolbx/Distrobox-Kontext"
hostnamectl
```

> **TIPP:** System-, Firewall-, Mount-, Treiber- und Deploymentbefehle immer in einem Host-Terminal ausführen. Paketmanagerbefehle wie `apt` oder `dnf` gehören normalerweise in die Distrobox.

## 3. Bazzite – Erste Schritte nach der Installation

### Version, Image und Kernel

```bash
cat /etc/os-release
grep -E '^(NAME|VERSION|VERSION_ID|VARIANT|VARIANT_ID|BUILD_ID|IMAGE_ID|IMAGE_VERSION)=' /etc/os-release
uname -r
uname -a
rpm-ostree status -v
bootc status 2>/dev/null || true
```

`rpm-ostree status -v` zeigt gebootetes, ausstehendes und vorheriges Deployment, Image-Quelle, Version, Layer und Overrides.

### CPU, RAM und Plattform

```bash
lscpu
free -h
grep -E 'MemTotal|MemAvailable|SwapTotal|SwapFree' /proc/meminfo
systemd-detect-virt
hostnamectl
```

### GPU, PCI, USB und Treiber

```bash
lspci -nnk
lspci -nnk | grep -A3 -Ei 'VGA|3D|Display'
lsusb
lsmod | sort
```

### Datenträger, Dateisysteme und Mountpoints

```bash
lsblk -e7 -o NAME,PATH,SIZE,TYPE,FSTYPE,FSVER,LABEL,UUID,MOUNTPOINTS,MODEL
blkid
findmnt --real
df -hT
df -ih
```

### Netzwerk, IP, Route und DNS

```bash
ip -brief link
ip -brief address
ip route
nmcli general status
nmcli device status
nmcli connection show --active
resolvectl status
hostnamectl hostname
```

### Zeit, Benutzer und Gruppen

```bash
timedatectl
id
groups
getent passwd "$USER"
loginctl user-status "$USER"
```

Hostname ändern:

```bash
sudo hostnamectl hostname bazzite-pc
hostnamectl hostname
```

> **ACHTUNG:** Bazzite dokumentiert wegen Distrobox eine Hostnamenslänge unter 20 Zeichen. Vorher exportierte Dienste und Container prüfen.

Rollback:

```bash
sudo hostnamectl hostname ALTER_HOSTNAME
```

`ALTER_HOSTNAME` ist ein **PLATZHALTER** für den zuvor mit `hostnamectl hostname` erfassten Wert.

### Secure Boot, TPM und Verschlüsselung

```bash
mokutil --sb-state
bootctl status 2>/dev/null || true
systemd-analyze has-tpm2
systemd-cryptenroll --tpm2-device=list 2>/dev/null || true
lsblk -f
sudo cryptsetup status $(lsblk -rno NAME,TYPE | awk '$2=="crypt"{print $1; exit}') 2>/dev/null || true
```

### Dienste und Bootzustand

```bash
systemctl is-system-running
systemctl --failed
systemctl list-units --type=service --state=running
systemd-analyze
systemd-analyze blame | head -n 30
journalctl -b -p warning --no-pager
```

### Flatpak, Brew und Container

```bash
flatpak --version
flatpak remotes --show-details
flatpak list --app --columns=application,name,version,installation
brew --version 2>/dev/null || true
distrobox list
podman version
podman ps --all
podman images
```

## 4. Erstdiagnose als Supportdatei

```bash
{
  echo '== OS =='
  cat /etc/os-release
  echo '== Kernel =='
  uname -a
  echo '== Deployments =='
  rpm-ostree status -v
  echo '== Failed units =='
  systemctl --failed
  echo '== Storage =='
  df -hT
  lsblk -f
  echo '== Network =='
  ip -brief address
  ip route
  echo '== Boot warnings =='
  journalctl -b -p warning --no-pager
} | tee ~/bazzite-health.txt
```

Verifikation:

```bash
test -s ~/bazzite-health.txt && wc -l ~/bazzite-health.txt
```

Rollback: Es wurde nur die Datei `~/bazzite-health.txt` erstellt. Sie kann nach Prüfung auf sensible Angaben mit `rm -i ~/bazzite-health.txt` entfernt werden.

# 07 Hardware, Gaming, Audio, Bluetooth und Sicherheit

## 1. Bazzite System Health Check

```bash
cat /etc/os-release
uname -r
rpm-ostree status -v
systemctl --failed
journalctl -b -p err --no-pager
lscpu
free -h
lsblk -f
df -hT
ip -brief address
resolvectl query example.org
flatpak remote-ls --updates
podman ps --all
fwupdmgr get-updates
mokutil --sb-state
```

Erweiterte Werkzeuge nur verwenden, wenn vorhanden oder in einer passenden Distrobox ausreichend. SMART/NVMe benötigen Host-Gerätezugriff; dafür die aktuelle Imageausstattung prüfen und Layering nur als letzte Wahl nutzen.

```bash
command -v smartctl nvme sensors stress-ng memtester
sudo smartctl --scan-open
sudo nvme list
sensors
```

> **ACHTUNG:** Stresstests erzeugen hohe Last und Temperatur. Temperaturen überwachen, Netzteil verwenden und bei Throttling/Fehlern abbrechen.

```bash
stress-ng --cpu 0 --timeout 60s --metrics-brief
memtester 1G 1
```

## 2. Hardwarediagnose

```bash
lscpu
free -h
sudo dmidecode -t system -t baseboard -t bios -t memory
lspci -nnk
lspci -nnk | grep -A3 -Ei 'VGA|3D|Display|Audio|Network|Ethernet'
lsusb
lsusb -t
bluetoothctl list
grep -E 'Handlers|Name' /proc/bus/input/devices
lsblk -o NAME,PATH,SIZE,MODEL,SERIAL,TRAN,FSTYPE,MOUNTPOINTS
sudo smartctl --scan-open
sudo nvme list
kscreen-doctor -o 2>/dev/null || true
gnome-randr 2>/dev/null || true
```

Hotplug live beobachten:

```bash
sudo journalctl -kf
udevadm monitor --kernel --udev --property
```

## 3. GPU, Mesa, Vulkan und OpenGL

```bash
lspci -nnk | grep -A3 -Ei 'VGA|3D|Display'
lsmod | grep -E 'amdgpu|i915|xe|nvidia|nouveau'
vulkaninfo --summary
vulkaninfo | grep -E 'Vulkan Instance Version|deviceName|driverName|driverInfo'
glxinfo -B
rpm -qa | grep -E '^mesa-(dri|vulkan|libGL|libEGL)'
journalctl -b -k -g 'drm|amdgpu|i915|xe|nvidia|nouveau' --no-pager
```

NVIDIA zusätzlich:

```bash
nvidia-smi
modinfo nvidia | head
rpm-ostree status -v
```

> **TIPP:** Bei GPU-Wechsel von/zu NVIDIA die korrekte Bazzite-Imagevariante prüfen und offiziell rebasen. Proprietäre Treiber nie mit einem Hersteller-`.run`-Installer in `/usr` installieren.

## 4. Steam, Proton, Gamescope und MangoHud

```bash
pgrep -a steam
pgrep -a gamescope
pgrep -a mangohud
ls -lah ~/.local/share/Steam/logs 2>/dev/null
```

Protonlog in den Steam-Startoptionen genau eines Spiels aktivieren:

```text
PROTON_LOG=1 %command%
```

Danach:

```bash
ls -lt ~/steam-*.log | head
vulkaninfo --summary
nvidia-smi 2>/dev/null || true
sensors 2>/dev/null || true
journalctl --user -b -g 'steam|gamescope|pressure-vessel' --no-pager
journalctl -b -k -g 'drm|gpu|oom' --no-pager
```

MangoHud-Startoption:

```text
mangohud %command%
```

> **INFO:** `gamemoderun %command%` wird von Bazzite nicht als allgemeine Optimierung unterstützt und kann Starts verhindern. Steam-Bibliotheken auf NTFS sind für PC-Gaming laut Bazzite nicht unterstützt.

## 5. Bluetooth

```bash
systemctl status bluetooth --no-pager
rfkill list
bluetoothctl list
bluetoothctl show
bluetoothctl devices
bluetoothctl paired-devices
journalctl -b -u bluetooth --no-pager
```

Interaktiv:

```bash
bluetoothctl
power on
agent on
default-agent
scan on
pair MAC_ADRESSE
trust MAC_ADRESSE
connect MAC_ADRESSE
disconnect MAC_ADRESSE
remove MAC_ADRESSE
quit
```

`MAC_ADRESSE` ist ein **PLATZHALTER**. `remove` erfordert danach erneutes Pairing.

## 6. PipeWire und WirePlumber

```bash
wpctl status
wpctl inspect @DEFAULT_AUDIO_SINK@
wpctl inspect @DEFAULT_AUDIO_SOURCE@
pactl info
pactl list short sinks
pactl list short sources
pactl list short sink-inputs
systemctl --user status pipewire pipewire-pulse wireplumber --no-pager
journalctl --user -b -u pipewire -u pipewire-pulse -u wireplumber --no-pager
```

```bash
wpctl set-default ID
wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
systemctl --user restart wireplumber pipewire pipewire-pulse
wpctl status
```

`ID` ist ein **PLATZHALTER** aus `wpctl status`.

## 7. Sicherheit ohne Gaming-Schäden

```bash
mokutil --sb-state
systemd-analyze has-tpm2
getenforce
sestatus
lsblk -f
sudo cryptsetup status LUKS_MAPPING
sudo -l
ss -tulpn
systemctl list-unit-files --state=enabled
firewall-cmd --state
last -a | head -n 30
lastb -a 2>/dev/null | head -n 30
journalctl -b _COMM=sudo --no-pager
```

`LUKS_MAPPING` ist ein **PLATZHALTER** aus `lsblk`.

```bash
flatpak info --show-permissions APP_ID
flatpak override --user --show APP_ID
podman ps --format '{{.Names}} {{.Image}} {{.Ports}}'
podman inspect CONTAINER --format '{{.HostConfig.Privileged}} {{.HostConfig.NetworkMode}}'
podman secret ls
```

> **TIPP:** SELinux aktiviert lassen, Flatpak-Rechte minimieren, Container rootless/unprivilegiert betreiben, unbekannte Ports schließen und automatische Updates nicht ohne belastbaren Ersatz deaktivieren.

> **WARNUNG:** Keine generischen Hardening-Skripte anwenden, die SELinux, Secure Boot, Gamescope, InputPlumber, PipeWire, Steam-Namespaces oder Bazzite-Updater verändern.

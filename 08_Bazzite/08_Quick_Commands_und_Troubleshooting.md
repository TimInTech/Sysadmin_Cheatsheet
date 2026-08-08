# 08 Quick Commands und Troubleshooting

## 1. Bazzite Quick Commands

| Zweck | Befehl |
|---|---|
| Version | `cat /etc/os-release` |
| Image/Deployment | `rpm-ostree status -v` |
| bootc-Status | `bootc status` |
| Kernel | `uname -r` |
| CPU | `lscpu` |
| RAM | `free -h` |
| GPU | `lspci -nnk \| grep -A3 -Ei 'VGA\|3D\|Display'` |
| IP | `ip -brief address` |
| Gateway | `ip route show default` |
| DNS | `resolvectl status` |
| Speicher | `df -hT` |
| Bootfehler | `journalctl -b -p err --no-pager` |
| Fehlgeschlagene Dienste | `systemctl --failed` |
| Offene Ports | `ss -tulpn` |
| Bazzite-Update | `ujust update` |
| Flatpak-Update | `flatpak update` |
| Rollback | `rpm-ostree rollback` |
| Neustart/Aus | `systemctl reboot` / `systemctl poweroff` |

## 2. Troubleshooting nach Fehlerbild

| Problem | Diagnose | Mögliche Ursache | Lösung |
|---|---|---|---|
| System startet nicht | GRUB `:1`, vorheriger Boot, Deploymentstatus | Defektes Deployment/Bootloader | Vorheriges Deployment; `brh rollback`; offizielles Live-Bootloader-Tool |
| Update fehlgeschlagen | `ujust update`, Status, Platz, rpm-ostreed-Log | Platz, Layerkonflikt, parallele Transaktion | Platzursache beheben; warten; problematischen Layer entfernen |
| Schwarzer Bildschirm | TTY, GPU-Kernellog, `lspci -nnk` | GPU-/Kernelregression, falsches Image | Vorheriges Deployment; passende Imagevariante prüfen |
| NVIDIA funktioniert nicht | `nvidia-smi`, Module, Secure Boot, Image | Falsches Image/Modul/Runtime | Offiziell rebasen; Update/Rollback; kein `.run`-Installer |
| AMD-GPU-Problem | Vulkan, amdgpu-/drm-Log | Mesa-/Kernelregression | Vorheriges Deployment; Host und Flatpak aktualisieren |
| Steam startet nicht | Prozesse, Steam-Logs, User-Journal | Prozess-/Runtimeproblem | Geordnet neu starten; Updates; Daten nicht blind löschen |
| Spiel startet nicht | Protonlog, Steam-Log | Proton, NTFS, Startoption | Optionen minimieren; unterstütztes Proton; Linux-Dateisystem |
| Proton funktioniert nicht | `~/steam-APPID.log`, Vulkan | Vulkan/Prefix/DRM | Vulkan zuerst; Prefix nur nach Save-Backup neu erstellen |
| Kein Vulkan | `vulkaninfo`, GPU/Treiber | Falsches Image, Runtime | Korrektes Image; `ujust update`; Flatpak-Update |
| Kein Netzwerk | NM, IP, Route, Journal | Funk blockiert, Profil/Link | `rfkill`; Profil kontrolliert neu verbinden |
| DNS funktioniert nicht | `resolvectl`, IP-Ping | Resolver/DHCP/VPN | Verbindung und VPN-DNS prüfen; Profil neu verbinden |
| WLAN fehlt | PCI, rfkill, Radio, Kernellog | Block, Firmware/Treiber | Block lösen; Rollback; Kompatibilität prüfen |
| Bluetooth defekt | rfkill, bluetoothctl, Journal | Block/Pairing/Controller | Power/Agent; neu pairen; Dienst neu starten |
| Kein Audio | `wpctl`, Userdienste, Journal | Standardgerät/Session | Gerät setzen; Audiostack neu starten |
| USB-Gerät fehlt | `lsusb -t`, Live-Log, udev | Kabel/Strom/Treiber | Port/Kabel testen; Kernelmeldung auswerten |
| Platte nicht erkannt | `lsblk`, Kernellog, SMART | Kabel/Controller/Defekt | Datenrettung priorisieren; keine Schreibreparatur |
| Btrfs-Fehler | Device Stats, Scrub, Kernel | Medium/Korruption | Backup; Scrub; SMART; kein ungeprüftes `--repair` |
| Flatpak startet nicht | `flatpak run`, History, Rechte | Commit/Override/Portal | Override reset; Repair; Appdaten sichern |
| Distrobox startet nicht | Liste, Podman, Containerlog | Image/Container | Daten sichern; aktualisieren oder reproduzierbar neu |
| Podman startet nicht | Info, Container, User-Journal | Storage/Netz/Quadlet | Speicher prüfen; Quadlet validieren; gezielt reparieren |
| systemd-Service defekt | Status, Unitlog, `systemctl cat` | Config/Abhängigkeit/Rechte | Ursache korrigieren; reload; Neustart und Prüfung |
| Speicherplatz voll | `df`, `du`, Komponentenbelegung | Logs, Images, Spiele, Snapshots | Quelle gezielt bereinigen; kein pauschales Löschen |
| `/var` voll | `du /var`, Podman, Snapper | Container/Logs/Snapshots | Retention/Bereinigung komponentenspezifisch |
| Home voll | `du "$HOME"`, große Dateien | Spiele/Downloads/Appdaten | Sichern/verschieben; App-eigene Bereinigung |

## 3. Standardablauf bei unbekanntem Fehler

1. Keine Reparaturbefehle aus fremden Fedora-/Ubuntu-Anleitungen ausführen.
2. Kontext, Version, Deployment und letzten fehlerfreien Boot erfassen.
3. Speicher, fehlgeschlagene Dienste und relevante Logs prüfen.
4. Bei Updatebeginn ein vorheriges Deployment testweise booten.
5. Nur die kleinste reversible Ursache korrigieren.
6. Nach Neustart denselben Diagnoseblock erneut ausführen.

```bash
cat /etc/os-release
uname -r
rpm-ostree status -v
systemctl --failed
df -hT
journalctl -b -p warning --no-pager
```

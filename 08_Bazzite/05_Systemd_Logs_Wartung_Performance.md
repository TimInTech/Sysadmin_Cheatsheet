# 05 systemd, Logs, Wartung und Performance

## 1. systemd-Dienste

### Anzeigen und prüfen

```bash
systemctl status DIENST --no-pager
systemctl is-active DIENST
systemctl is-enabled DIENST
systemctl --failed
systemctl list-units --type=service
systemctl list-unit-files --type=service
systemctl list-dependencies DIENST
systemctl show DIENST
```

### Ändern

```bash
sudo systemctl start DIENST
sudo systemctl stop DIENST
sudo systemctl restart DIENST
sudo systemctl reload DIENST
sudo systemctl enable DIENST
sudo systemctl disable DIENST
sudo systemctl mask DIENST
sudo systemctl unmask DIENST
```

> **ACHTUNG:** Vor Stop, Disable oder Mask Abhängigkeiten und Konsolenzugang prüfen. Rollback ist die jeweilige Gegenoperation und anschließende Statusprüfung.

Benutzerdienste ohne `sudo`:

```bash
systemctl --user status DIENST
systemctl --user restart DIENST
systemctl --user --failed
```

## 2. Journal und Bootanalyse

```bash
journalctl -b --no-pager
journalctl -b -p err --no-pager
journalctl -b -p warning --no-pager
journalctl -b -k --no-pager
journalctl -u DIENST -b --no-pager
journalctl -u DIENST --since '2026-08-08 10:00' --until '2026-08-08 11:00'
journalctl -f
journalctl --list-boots
journalctl -b -1 -p warning --no-pager
systemd-analyze
systemd-analyze blame
systemd-analyze critical-chain
```

## 3. Wo finde ich Fehler unter Bazzite?

| Bereich | Diagnose |
|---|---|
| Host/Boot | `journalctl -b -p warning`, `journalctl -b -k` |
| Deployment | `rpm-ostree status -v`, `journalctl -u rpm-ostreed` |
| bootc | `bootc status`, `journalctl -b -g bootc` |
| Flatpak | `flatpak history`, `flatpak run APP_ID`, `journalctl --user -b` |
| Podman | `podman logs CONTAINER`, `podman events --since 1h` |
| Distrobox | `distrobox list`, `podman logs CONTAINER` |
| GPU | `journalctl -b -k -g 'drm\|amdgpu\|i915\|xe\|nvidia\|nouveau'` |
| Netzwerk | `journalctl -b -u NetworkManager`, `resolvectl status` |
| Bluetooth | `journalctl -b -u bluetooth`, `rfkill list` |
| USB | `journalctl -kf`, `lsusb -t` |
| Storage | `journalctl -b -k -g 'I/O error\|nvme\|ata\|btrfs\|ext4'` |
| Mounts | `systemctl --failed`, `findmnt --verify`, `journalctl -b -g mount` |

Bazzite-Supportausgabe, falls vorhanden:

```bash
ujust logs-last-boot > ~/bazzite-last-boot.txt
test -s ~/bazzite-last-boot.txt && wc -l ~/bazzite-last-boot.txt
```

Vor Veröffentlichung auf Benutzernamen, IPs, Seriennummern, Mountpfade und Tokens prüfen.

## 4. Prozesse und Performance

```bash
uptime
free -h
vmstat 1 10
ps aux --sort=-%cpu | head -n 20
ps aux --sort=-%mem | head -n 20
top
pgrep -a PROZESS
systemd-cgtop
```

Falls installiert:

```bash
btop
htop
iostat -xz 1 10
sensors
```

Bazzite entfernt `htop` derzeit aus dem Basisimage; `btop` ist die passende Hostalternative. Falls `htop` ausdrücklich benötigt wird, als CLI-Werkzeug mit `brew install htop` installieren. `iostat` bei fehlendem Hostwerkzeug nur dann layern, wenn Messungen im Hostnamespace zwingend sind.

Prozess geordnet beenden:

```bash
kill PID
sleep 2
ps -p PID
```

Nur wenn er nicht reagiert:

```bash
kill -KILL PID
```

> **ACHTUNG:** `pkill` und `kill -KILL` können ungespeicherte Daten verlieren. PID/Prozessname zuerst mit `ps` oder `pgrep -a` verifizieren.

## 5. Regelmäßige Wartung

### Sicher: Zustand prüfen

```bash
rpm-ostree status -v
systemctl --failed
df -hT
df -ih
journalctl --disk-usage
flatpak uninstall --unused --assumeno
podman system df
fwupdmgr get-updates
```

### Große Verzeichnisse finden

```bash
du -xhd1 "$HOME" 2>/dev/null | sort -h
sudo du -xhd1 /var 2>/dev/null | sort -h
find "$HOME" -xdev -type f -size +2G -printf '%s %p\n' 2>/dev/null | sort -n
```

### Journal begrenzen

```bash
journalctl --disk-usage
sudo journalctl --vacuum-time=30d
journalctl --disk-usage
```

> **ACHTUNG:** Alte Logs werden dauerhaft gelöscht. Relevante Incident-/Supportlogs vorher exportieren. Gelöschte Journale sind nicht wiederherstellbar.

### Temporäre Dateien

```bash
systemd-tmpfiles --clean --dry-run 2>/dev/null || true
sudo systemd-tmpfiles --clean
```

> **TIPP:** Keine pauschalen `rm -rf`-Bereinigungen in `/var`, `~/.cache`, Steam- oder Flatpak-Verzeichnissen. Erst Verursacher und Wiederherstellbarkeit bestimmen.

## 6. Systemzustand nach Änderung verifizieren

```bash
systemctl is-system-running
systemctl --failed
journalctl -b -p err --no-pager
rpm-ostree status -v
df -hT
```

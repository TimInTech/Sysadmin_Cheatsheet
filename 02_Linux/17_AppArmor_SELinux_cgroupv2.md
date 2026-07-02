# 17 AppArmor, SELinux und cgroupv2 (Linux)

Sicherheitsprofile und Container-Kompatibilitaet prüfen.

Quellen:

- AppArmor Wiki: <https://gitlab.com/apparmor/apparmor/-/wikis/home>
- SELinux Project: <https://github.com/SELinuxProject>
- cgroupv2 Documentation: <https://www.kernel.org/doc/html/latest/admin-guide/cgroup-v2.html>

## 1. AppArmor

```bash
systemctl status apparmor --no-pager 2>/dev/null || true
sudo aa-status 2>/dev/null || true
```

## 2. SELinux

```bash
getenforce 2>/dev/null || echo 'SELinux-Befehl nicht vorhanden'
sestatus 2>/dev/null || true
```

## 3. cgroup-Version

```bash
stat -fc %T /sys/fs/cgroup
mount | grep cgroup
```

## 4. AppArmor-Denies im Journal

```bash
journalctl -b --no-pager | grep -i apparmor | tail -n 100
```

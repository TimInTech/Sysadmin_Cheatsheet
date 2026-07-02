# 14 Systeminformationen (Linux)

Distro, Kernel, Bootmodus, Hardware und Zeitdiagnose mit Bordmitteln.

Quellen:

- Debian Reference: <https://www.debian.org/doc/manuals/debian-reference/>
- Ubuntu Server Docs: <https://ubuntu.com/server/docs/>

## 1. Basisdaten

```bash
hostnamectl
cat /etc/os-release
uname -a
dpkg --print-architecture
```

## 2. Bootmodus prüfen

```bash
# UEFI = Verzeichnis vorhanden, BIOS-Legacy = nicht vorhanden
if test -d /sys/firmware/efi; then echo UEFI; else echo BIOS-Legacy; fi
```

## 3. Hardware und Storage

```bash
lscpu
free -h
lsblk -f
lspci -nn
lsusb
```

## 4. Zeit und Locale

```bash
timedatectl
localectl status
```

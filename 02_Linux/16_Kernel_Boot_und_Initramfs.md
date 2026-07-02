# 16 Kernel, Boot und Initramfs (Linux)

Kernelversion, Bootmeldungen, Initramfs und GRUB-Verifikation.

Quellen:

- Debian Reference: <https://www.debian.org/doc/manuals/debian-reference/>
- Ubuntu Server Docs: <https://ubuntu.com/server/docs/>

## 1. Kernel prüfen

```bash
uname -r
dpkg -l 'linux-image*' 'linux-headers*' 2>/dev/null | awk '/^ii/ {print $2, $3}'
```

## 2. Bootmeldungen anzeigen

```bash
journalctl -k -b --no-pager
dmesg -T --level=err,warn
```

## 3. Boot-Partition prüfen

```bash
df -hT /boot / 2>/dev/null
ls -lah /boot
```

## 4. Initramfs neu erzeugen

> **Warnung:** Bootrelevante Aenderung. Vorher freien Platz auf `/boot` pruefen.

```bash
df -hT /boot / 2>/dev/null
sudo update-initramfs -u -k all
```

## 5. GRUB-Konfiguration neu erzeugen

> **Warnung:** Bootrelevante Aenderung. Nach Aenderungen an `/etc/default/grub` oder neuen Kerneln ausfuehren.

```bash
sudo update-grub
```

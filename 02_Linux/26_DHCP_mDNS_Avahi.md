# 26 DHCP, mDNS und Avahi (Linux)

DHCP-Leases abfragen und mDNS/Avahi-Dienste im Netzwerk erkennen.

Quellen:

- Avahi Documentation: <https://avahi.org/>
- systemd-networkd Manual: <https://www.freedesktop.org/software/systemd/man/networkctl.html>

## 1. DHCP-Leases anzeigen

```bash
# Via NetworkManager
nmcli device show 2>/dev/null | grep -E 'IP4|DHCP' || true

# Via systemd-networkd
networkctl status 2>/dev/null || true

# Im Journal
journalctl -b --no-pager | grep -Ei 'dhcp|lease' | tail -n 120
```

## 2. mDNS/Avahi-Status und Dienste

```bash
systemctl status avahi-daemon --no-pager 2>/dev/null || true
avahi-browse -at 2>/dev/null | head -n 80 || true
```

# 24 PiHole und Unbound (HomeLab-DNS)

Pi-hole als DNS-Sinkhole und Unbound als rekursiver Resolver – Status, Logs und Client-Pruefung.

Quellen:

- Pi-hole Documentation: <https://docs.pi-hole.net/>
- Unbound Documentation: <https://unbound.docs.nlnetlabs.nl/>

## 1. PiHole-Status und Version

```bash
pihole status
pihole -v
systemctl status pihole-FTL --no-pager
```

## 2. PiHole-Logs und Diagnose

```bash
pihole tail
pihole -d
```

## 3. PiHole deaktivieren / aktivieren

```bash
# Fuer 5 Minuten deaktivieren (ohne Zeitangabe = dauerhaft)
pihole disable 5m
pihole enable
```

## 4. PiHole-Gravity-Update (Blocklisten neu laden)

```bash
pihole updateGravity
```

## 5. Unbound-Status und Konfiguration

```bash
unbound -V 2>/dev/null || true
systemctl status unbound --no-pager
sudo unbound-checkconf
```

## 6. Unbound-Statistiken

```bash
unbound-control stats 2>/dev/null || true
```

## 7. Unbound-Logs

```bash
journalctl -u unbound -b --no-pager | tail -n 180
```

## 8. Client-DNS prufen (Linux)

```bash
resolvectl status
cat /etc/resolv.conf
dig example.com
```

## 9. Client-DNS prufen (Windows PowerShell)

```powershell
Get-DnsClientServerAddress
Resolve-DnsName example.com
ipconfig /all
```

## 10. DHCP-/DNS-Konflikte erkennen

```bash
journalctl -b --no-pager | grep -Ei 'dhcp|offer|lease' | tail -n 160
nmcli device show 2>/dev/null | grep -Ei 'dhcp|dns|gateway' || true
ip route
```

## 11. Split-DNS und lokale Namen prüfen

```bash
HOST=meinserver
getent hosts "$HOST"
getent hosts "$HOST.local" || true
avahi-browse -at 2>/dev/null | head -n 80 || true
```

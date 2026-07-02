# 23 DNS-Diagnose (Linux)

Resolver, direkte DNS-Abfragen und Nameserver-Test mit Bordmitteln.

Quellen:

- systemd-resolved Manual: <https://man7.org/linux/man-pages/man8/systemd-resolved.service.8.html>
- dig Manual: <https://man7.org/linux/man-pages/man1/dig.1.html>

## 1. Resolverstatus

```bash
resolvectl status 2>/dev/null || true
cat /etc/resolv.conf
```

## 2. Namensauflösung testen

```bash
getent hosts example.com
resolvectl query example.com 2>/dev/null || true
dig example.com 2>/dev/null || true
```

## 3. DNS-Server direkt testen

```bash
dig @1.1.1.1 example.com 2>/dev/null || true
dig @8.8.8.8 example.com 2>/dev/null || true
```

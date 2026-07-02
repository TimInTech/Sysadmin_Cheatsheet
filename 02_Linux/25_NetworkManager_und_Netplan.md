# 25 NetworkManager und Netplan (Linux)

Aktiven Netzwerk-Stack erkennen und Netplan-Konfiguration sicher testen.

> **Warnung:** `netplan try` aktiviert die Konfiguration mit Timeout. Bei Remote-Systemen kann ein Fehler zum Aussperren fuehren. Vorher immer eine zweite Sitzung offen halten oder Konsolen-Zugriff sicherstellen.

Quellen:

- Netplan Documentation: <https://netplan.readthedocs.io/>
- NetworkManager Docs: <https://networkmanager.dev/docs/>

## 1. Aktiven Netzwerk-Stack erkennen

```bash
systemctl is-active NetworkManager 2>/dev/null || true
systemctl is-active systemd-networkd 2>/dev/null || true
nmcli general status 2>/dev/null || true
networkctl list 2>/dev/null || true
```

## 2. Netplan-Konfiguration prüfen

```bash
ls -lah /etc/netplan 2>/dev/null || true
grep -RhsE '^[^#]' /etc/netplan/*.yaml 2>/dev/null || true
```

## 3. Netplan try (sicherer Test)

```bash
sudo netplan try
```

## 4. nmcli-Grundlagen

```bash
# Verbindungen auflisten
nmcli connection show

# Status aller Interfaces
nmcli device status

# Details zu einem Interface
nmcli device show INTERFACE
```

# 03 Netzwerk und Dienste (Linux)

Wartung von Hintergrunddiensten und Netzwerksicherheit.

## 0. IP, Routing und Gateway

```bash
# Link-Status aller Interfaces
ip -br link

# IP-Adressen aller Interfaces
ip -br address

# Routing-Tabelle anzeigen
ip route

# Default-Gateway ermitteln
ip route get 1.1.1.1

# Gateway anpingen
ping -c 4 1.1.1.1

# ARP-/Neighbor-Tabelle
ip neigh

# Link-Details (Duplex, Geschwindigkeit)
ethtool "$(ip route | awk '/default/ {print $5; exit}')" 2>/dev/null || true
```

## 1. Systemd-Services verwalten

Nahezu alle modernen Linux-Distributionen (Ubuntu, Debian, CentOS) nutzen `systemd` zur Verwaltung von Hintergrunddiensten.

```bash
# Distro-abhaengigen SSH-Servicenamen zuerst ermitteln
systemctl list-unit-files 'ssh*.service'

# Status eines Dienstes abfragen (z.B. SSH-Server)
sudo systemctl status ssh

# Dienst neu starten (Name kann je nach Distribution ssh oder sshd sein)
sudo systemctl restart ssh

# Dienst stoppen / starten
sudo systemctl stop ssh
sudo systemctl start ssh

# Autostart beim System-Boot aktivieren/deaktivieren
sudo systemctl enable ssh
sudo systemctl disable ssh
```

## 1.1 Listening Ports und Dienste

```bash
# Alle offenen Ports und zugehörige Dienste anzeigen
sudo ss -tulpn

# Bestimmten Port prüfen
sudo ss -tulpn | awk -v port=":443" '$0 ~ port'

# Dienst zu einem Port ermitteln
sudo lsof -iTCP:443 -sTCP:LISTEN -P -n 2>/dev/null || true
```

## 1.2 Remote-Lockout vor Firewall-Änderungen prüfen

```bash
# Eigene Session bestätigen
who

# SSH-Port prüfen
sudo ss -tulpn | grep -E ':22|:2222' || true

# UFW-Regeln mit Nummern anzeigen
sudo ufw status numbered 2>/dev/null || true

# nftables-Regeln anzeigen
sudo nft list ruleset 2>/dev/null || true
```

## 2. UFW (Uncomplicated Firewall)

UFW ist das Standard-Firewall-Tool für Ubuntu/Debian.

### 2.1 Standard-Regelwerke anwenden
```bash
# UFW aktivieren (Achtung: Erlaubt standardmäßig keinen eingehenden Verkehr!)
sudo ufw enable

# Status und aktive Regeln anzeigen
sudo ufw status verbose

# Standard: Alles eingehende blockieren, alles ausgehende erlauben
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

### 2.2 Spezifische Ports/Dienste freigeben
```bash
# WICHTIG: SSH vor Aktivierung freigeben, sonst sperrt man sich aus dem Server aus!
sudo ufw allow ssh
# Alternativ über den Port:
sudo ufw allow 22/tcp

# Webserver (HTTP/HTTPS) freigeben
sudo ufw allow http
sudo ufw allow https

# Eine bestimmte IP-Adresse komplett zulassen
sudo ufw allow from 192.168.1.100

# Regel wieder löschen (nach Nummer oder Name)
sudo ufw delete allow ssh
sudo ufw status numbered
sudo ufw delete NUM
```

### 2.3 UFW-Regel mit Nummerierung verwalten

```bash
# Mit Nummerierung (einfacher für delete)
sudo ufw status numbered

# Neue Regel hinzufügen
sudo ufw allow 443/tcp

# Regel nach Nummer löschen (vorher numbered anzeigen!)
sudo ufw delete 3
sudo ufw status numbered
```

## 3. Logs auslesen
Systemd protokolliert zentral mit `journalctl`.
```bash
# Die letzten 50 Zeilen der System-Logs anzeigen
journalctl -n 50

# Logs live mitlesen
journalctl -f

# Spezifisch für einen Dienst filtern (z.B. SSH)
journalctl -u ssh -f
```

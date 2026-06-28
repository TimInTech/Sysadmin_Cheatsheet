# 03 Netzwerk und Dienste (Linux)

Wartung von Hintergrunddiensten und Netzwerksicherheit.

## 1. Systemd-Services verwalten

Nahezu alle modernen Linux-Distributionen (Ubuntu, Debian, CentOS) nutzen `systemd` zur Verwaltung von Hintergrunddiensten.

```bash
# Status eines Dienstes abfragen (z.B. SSH-Server)
sudo systemctl status ssh

# Dienst neu starten (hilft oft bei Konfigurationsfehlern)
sudo systemctl restart ssh

# Dienst stoppen / starten
sudo systemctl stop ssh
sudo systemctl start ssh

# Autostart beim System-Boot aktivieren/deaktivieren
sudo systemctl enable ssh
sudo systemctl disable ssh
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

# Regel wieder löschen
sudo ufw delete allow ssh
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

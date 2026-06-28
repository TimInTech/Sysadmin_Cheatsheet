# SSH und Remote-Zugriff (Linux)

Bei der Remote-Administration via Secure Shell (SSH) treten oft Berechtigungs- oder Verbindungsprobleme auf. Hier finden sich die häufigsten Fehler und deren Lösungen.

## 1. SSH-Dienst Status und Logs

Wenn eine Verbindung abgelehnt wird (`Connection refused`), sollte zuerst auf der Konsole (oder über ein KVM/IPMI-Interface) der Dienst geprüft werden:

```bash
# Status des SSH-Dienstes abfragen
systemctl status sshd

# SSH-Dienst neu starten (z. B. nach Konfigurationsänderung in /etc/ssh/sshd_config)
sudo systemctl restart sshd

# Live-Logs des SSH-Dienstes lesen (hilft bei fehlgeschlagenen Logins)
sudo journalctl -u sshd -f
```

## 2. Berechtigungsprobleme (Permission Denied / Publickey)

SSH ist extrem strikt, was die Dateiberechtigungen von Schlüsseln und `.ssh`-Verzeichnissen angeht. Wenn ein Key abgelehnt wird, liegt es meist an zu offenen Rechten.

Auf dem **Client** (der Rechner, der sich verbindet):
```bash
# Private Key darf nur für den Besitzer lesbar sein
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_ed25519
```

Auf dem **Server** (der Rechner, zu dem verbunden wird):
```bash
# Das .ssh Verzeichnis darf nur für den Besitzer zugänglich sein
chmod 700 ~/.ssh

# Die authorized_keys Datei darf nicht von anderen beschreibbar sein
chmod 600 ~/.ssh/authorized_keys

# Sicherstellen, dass das Verzeichnis dem richtigen Benutzer gehört
sudo chown -R $USER:$USER ~/.ssh
```

## 3. SSH Port-Forwarding (Tunneling)

Um einen blockierten oder lokalen Port eines Remote-Servers über SSH auf den eigenen Rechner weiterzuleiten (z. B. um eine lokale Datenbank oder ein Web-Interface des Servers sicher zu erreichen):

**Lokales Port-Forwarding:**
Leitet den Port 8080 des Remote-Servers `server_ip` auf den lokalen Port `8080` weiter.
```bash
ssh -L 8080:localhost:8080 benutzer@server_ip
```
*(Anschließend ist der Dienst im lokalen Browser unter `http://localhost:8080` erreichbar).*

**Dynamisches Port-Forwarding (SOCKS Proxy):**
Nützlich, um den gesamten Browser-Traffic sicher durch den Server zu tunneln (lokaler Port 1080).
```bash
ssh -D 1080 benutzer@server_ip
```

## 4. SSH-Sitzungen offen halten

Wenn SSH-Sitzungen bei Inaktivität einfrieren ("Broken pipe"), kann man dem Client anweisen, regelmäßig Keep-Alive-Pakete zu senden:
```bash
# Für eine einmalige Verbindung:
ssh -o ServerAliveInterval=60 benutzer@server_ip
```
Alternativ dauerhaft in der `~/.ssh/config` hinterlegen:
```text
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

# SSH und Remote-Zugriff (Linux)

Bei der Remote-Administration via Secure Shell (SSH) treten oft Berechtigungs- oder Verbindungsprobleme auf. Hier finden sich die häufigsten Fehler und deren Lösungen.

## 0. Version und Debugging

```bash
# Installierte OpenSSH-Version
ssh -V

# Debug-Verbindung (bis zu 3 v für mehr Details)
ssh -vvv benutzer@host true
```

## 1. SSH-Dienst Status und Logs

Wenn eine Verbindung abgelehnt wird (`Connection refused`), sollte zuerst auf der Konsole (oder über ein KVM/IPMI-Interface) der Dienst geprüft werden:

```bash
# Distro-abhaengigen Servicenamen zuerst ermitteln (haeufig ssh oder sshd)
systemctl list-unit-files 'ssh*.service'

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
# Vorhandene SSH-Dateien anzeigen
ls -lah ~/.ssh

# Private Key darf nur für den Besitzer lesbar sein
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_ed25519

# Alle privaten Keys korrekt setzen
find ~/.ssh -maxdepth 1 -type f -name 'id_*' ! -name '*.pub' -exec chmod 600 {} \;
find ~/.ssh -maxdepth 1 -type f -name '*.pub' -exec chmod 644 {} \;
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

### 2.1 ssh-agent verwenden

Der ssh-agent speichert entsperrte Private Keys im Speicher, sodass das Passwort nicht bei jeder Verbindung erneut eingegeben werden muss.

```bash
# Agent starten und Umgebungsvariablen setzen
eval "$(ssh-agent)"

# Geladene Keys anzeigen
ssh-add -l

# Key zum Agent hinzufügen
ssh-add ~/.ssh/id_ed25519
```

## 3. sshd_config prüfen und sichern

Vor Änderungen an der SSH-Konfiguration immer Syntax und Backup prüfen.

```bash
# Syntax der aktuellen sshd_config prüfen
sudo sshd -t

# Effektive Konfiguration anzeigen (inklusive aller Includes)
sudo sshd -T | sort

# Backup der Konfiguration anlegen
sudo cp -a /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%Y%m%d-%H%M%S).bak
```

## 4. SSH Port-Forwarding (Tunneling)

Um einen blockierten oder lokalen Port eines Remote-Servers über SSH auf den eigenen Rechner weiterzuleiten (z. B. um eine lokale Datenbank oder ein Web-Interface des Servers sicher zu erreichen):

**Lokales Port-Forwarding (-L):**
Leitet den Port 8080 des Remote-Servers `server_ip` auf den lokalen Port `8080` weiter.
```bash
ssh -L 8080:localhost:8080 benutzer@server_ip
```
*(Anschließend ist der Dienst im lokalen Browser unter `http://localhost:8080` erreichbar).*

**Remote Port-Forwarding (-R):**
Leitet einen lokalen Port zum Remote-Server weiter. Ermöglicht Remote-Rechnern Zugriff auf lokale Dienste (z. B. hinter NAT).
```bash
ssh -R 8080:localhost:80 benutzer@server_ip
# Der Remote-Server kann nun localhost:8080 nutzen, der auf den lokalen Port 80 zeigt.
```

**SOCKS-Proxy (-D):**
Nützlich, um den gesamten Browser-Traffic sicher durch den Server zu tunneln (lokaler Port 1080).
```bash
ssh -D 1080 benutzer@server_ip
```

**Jump-Host (-J):**
Durch einen Bastion-Host zur Zielmaschine verbinden.
```bash
ssh -J benutzer@bastion_host benutzer@ziel_host
```

## 5. Remote-Lockout vermeiden

Bei Remote-Administration kann eine fehlerhafte Konfiguration zum Aussperren führen. Vor dem Schließen der aktuellen Verbindung immer prüfen:

```bash
# Eigene Session bestätigen
who

# Prüfen ob SSH auf dem richtigen Port lauscht
sudo ss -tulpn | grep -E ':22|sshd' || true

# Firewall-Regeln für SSH prüfen
sudo ufw status numbered 2>/dev/null || true
```

> **Warnung:** Nie die letzte SSH-Session schließen, ohne eine zweite SSH-Verbindung getestet zu haben. Bei Konfigurationsänderungen: `sudo sshd -t` vor Restart und `sudo systemctl restart sshd` in eine zweite, getrennte Session legen.

```bash
# Empfohlenes Vorgehen vor Konfig-Änderung:
# 1. Zweite SSH-Session öffnen (nicht schließen!)
# 2. Config ändern und mit sshd -t prüfen
# 3. Restart in der ersten Session
# 4. Verbindung in der zweiten Session prüfen
# 5. Erst danach die erste Session schließen
```

## 6. SSH-Sitzungen offen halten

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

## 7. SSH-Server härten

Kurz gesagt: Anmeldung nur noch mit Schlüssel, kein direkter Root-Login, wenige Fehlversuche. Mehr braucht ein typischer Heim- oder Laborserver nicht. Die Verschlüsselungsverfahren (Kex, Ciphers, MACs) bleiben auf den Standardwerten: Aktuelles OpenSSH wählt sie bereits sicher, und eigene Listen schalten oft neuere Verfahren ab. OpenSSH 10.2 nutzt zum Beispiel zuerst den Post-Quanten-Schlüsseltausch `mlkem768x25519-sha256`, der in vielen alten Härtungsanleitungen fehlt.

> **Warnung:** Mit `PasswordAuthentication no` kommt nur noch rein, wessen öffentlicher Schlüssel in `~/.ssh/authorized_keys` liegt. Vorher die Anmeldung per Schlüssel testen und eine zweite Sitzung offen lassen (siehe [Abschnitt 5](#5-remote-lockout-vermeiden)). Sonst sperrst du dich aus.

### 7.1 Vorher prüfen

```bash
# Muss ohne Passwortabfrage klappen (von einem zweiten Terminal aus)
ssh -o PasswordAuthentication=no benutzer@server_ip true && echo "Schlüssel-Login funktioniert"

# Vorhandene Zusatzdateien ansehen (z. B. 50-cloud-init.conf mit PasswordAuthentication yes)
ls -l /etc/ssh/sshd_config.d/
```

### 7.2 Härtung als eigene Datei

sshd übernimmt für jede Option den **ersten** gefundenen Wert. Die Datei heißt deshalb `00-haertung.conf`, damit sie vor anderen Zusatzdateien gelesen wird. Das setzt voraus, dass `/etc/ssh/sshd_config` die Zusatzdateien am Anfang einbindet (`Include /etc/ssh/sshd_config.d/*.conf`), wie unter Ubuntu und Debian üblich.

```bash
sudo tee /etc/ssh/sshd_config.d/00-haertung.conf >/dev/null <<'EOF'
# Nur Schlüssel-Anmeldung
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
# Kein direkter Root-Login
PermitRootLogin no
# Weniger Fehlversuche und kürzere Wartezeit
MaxAuthTries 3
LoginGraceTime 30
EOF
```

`Protocol 2` aus älteren Anleitungen ist überflüssig: Seit OpenSSH 7.4 gibt es nur noch Protokoll 2.

### 7.3 Prüfen, anwenden, kontrollieren

```bash
# 1. Syntax prüfen; bei Fehlern NICHT weitermachen
sudo sshd -t

# 2. Wirksame Werte anzeigen
sudo sshd -T | grep -Ei '^(permitrootlogin|passwordauthentication|kbdinteractiveauthentication|maxauthtries|logingracetime)'

# 3. Konfiguration neu laden (Ubuntu/Debian: ssh, Fedora/Bazzite: sshd)
sudo systemctl reload ssh

# 4. In einem NEUEN Terminal anmelden, erst danach die alte Sitzung schließen
ssh benutzer@server_ip
```

Bestehende Sitzungen bleiben beim Neuladen offen. Läuft `ssh.service` unter Ubuntu gerade nicht (Socket-Aktivierung), meldet `reload` einen Fehler. Das ist dann unkritisch, weil die nächste Verbindung die neue Konfiguration liest.

**Rollback:**

```bash
sudo rm /etc/ssh/sshd_config.d/00-haertung.conf
sudo sshd -t && sudo systemctl reload ssh
```

Getestet auf: Ubuntu 26.04 mit OpenSSH 10.2p1 (Syntax und wirksame Werte mit `sshd -t` und `sshd -T` in einer Testkonfiguration geprüft, kein Live-Server). Quelle: [sshd_config(5)](https://man.openbsd.org/sshd_config).

**Firewall und Sperren nach Fehlversuchen** stehen auf eigenen Seiten: [Netzwerk und Dienste (UFW)](03_Netzwerk_und_Dienste.md), [nftables Firewall](11_Nftables_Firewall.md) und [Fail2ban](20_Fail2ban.md).

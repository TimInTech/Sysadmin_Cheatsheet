# 04 Netzwerk, Firewall, SSH und Samba

## 1. Netzwerkdiagnose

```bash
ip -brief link
ip -brief address
ip route
ip neigh
nmcli general status
nmcli device status
nmcli connection show --active
nmcli radio
nmcli device wifi list
resolvectl status
resolvectl query example.org
ss -tulpn
ss -s
```

Konnektivität schrittweise prüfen:

```bash
ping -c 4 ROUTER_IP
ping -c 4 1.1.1.1
getent ahosts example.org
curl -I --connect-timeout 10 https://example.org
tracepath example.org
```

`ROUTER_IP` ist ein **PLATZHALTER** aus `ip route`.

Werkzeugverfügbarkeit:

```bash
for cmd in ip ss nmcli resolvectl ping tracepath traceroute curl wget dig host nslookup; do
  command -v "$cmd" || echo "fehlt: $cmd"
done
```

Fehlende Diagnoseprogramme bevorzugt kurzzeitig in einer Fedora-Distrobox nutzen. Nur wenn Host-Netzwerknamespace oder hostnahe Capabilities erforderlich sind, ein Host-Layer erwägen.

## 2. NetworkManager

```bash
nmcli connection show
nmcli connection show VERBINDUNG
nmcli device show INTERFACE
nmcli device wifi rescan
nmcli device wifi list
nmcli networking connectivity check
journalctl -b -u NetworkManager --no-pager
```

Verbindung neu aktivieren:

```bash
nmcli connection down VERBINDUNG
nmcli connection up VERBINDUNG
nmcli general status
```

> **ACHTUNG:** Remoteverbindungen können abbrechen. Vor Änderungen Konsolenzugang und bisherigen Profilnamen sichern.

## 3. firewalld

Bazzite erbt den Fedora-Atomic-Netzwerkstack mit firewalld; die tatsächliche Installation und Aktivität immer lokal prüfen. firewalld verwaltet auf modernen Fedora-Systemen typischerweise nftables im Hintergrund. Keine parallelen direkten nftables-/iptables-Regeln pflegen.

### Status und Inventar

```bash
rpm -q firewalld
systemctl status firewalld --no-pager
firewall-cmd --state
firewall-cmd --get-default-zone
firewall-cmd --get-active-zones
firewall-cmd --get-zones
firewall-cmd --get-services
firewall-cmd --list-all
firewall-cmd --list-all-zones
firewall-cmd --get-zone-of-interface=INTERFACE
```

### Dienst verwalten

```bash
sudo systemctl enable --now firewalld
sudo systemctl restart firewalld
sudo systemctl stop firewalld
```

> **WARNUNG:** Stoppen oder Deaktivieren entfernt den Hostschutz. Nur in einem kontrollierten Wartungsfenster und nicht als Fehlerbehebung für einzelne Ports.

Rollback:

```bash
sudo systemctl enable --now firewalld
firewall-cmd --state
```

### Temporär testen, dann permanent speichern

```bash
sudo firewall-cmd --zone=ZONE --add-service=DIENST
sudo firewall-cmd --zone=ZONE --query-service=DIENST
sudo firewall-cmd --runtime-to-permanent
sudo firewall-cmd --zone=ZONE --list-all
```

`ZONE` und `DIENST` sind **PLATZHALTER** aus der vorherigen Diagnose.

Rollback einer Servicefreigabe:

```bash
sudo firewall-cmd --zone=ZONE --remove-service=DIENST
sudo firewall-cmd --permanent --zone=ZONE --remove-service=DIENST
sudo firewall-cmd --reload
```

### Ports, Bereiche und Protokolle

```bash
sudo firewall-cmd --zone=ZONE --add-port=PORT/tcp
sudo firewall-cmd --zone=ZONE --add-port=PORT/udp
sudo firewall-cmd --zone=ZONE --add-port=START-END/tcp
sudo firewall-cmd --runtime-to-permanent
```

Entfernen:

```bash
sudo firewall-cmd --zone=ZONE --remove-port=PORT/tcp
sudo firewall-cmd --permanent --zone=ZONE --remove-port=PORT/tcp
sudo firewall-cmd --reload
```

### Rich Rules für IP und Subnetz

```bash
sudo firewall-cmd --zone=ZONE --add-rich-rule='rule family="ipv4" source address="192.0.2.10/32" service name="ssh" accept'
sudo firewall-cmd --zone=ZONE --add-rich-rule='rule family="ipv4" source address="192.0.2.0/24" service name="samba" accept'
sudo firewall-cmd --zone=ZONE --add-rich-rule='rule family="ipv4" source address="198.51.100.20/32" log prefix="firewalld-drop " limit value="3/m" drop'
sudo firewall-cmd --zone=ZONE --list-rich-rules
```

Erst als Runtime-Regel testen, anschließend mit `--runtime-to-permanent` speichern. Entfernen erfolgt mit exakt derselben Regel und `--remove-rich-rule=...`.

### Typische Dienste

```bash
firewall-cmd --get-services | tr ' ' '\n' | grep -E '^(ssh|http|https|samba|kdeconnect|syncthing)$'
sudo firewall-cmd --zone=ZONE --add-service=ssh
sudo firewall-cmd --zone=ZONE --add-service=http
sudo firewall-cmd --zone=ZONE --add-service=https
sudo firewall-cmd --zone=ZONE --add-service=samba
sudo firewall-cmd --zone=ZONE --add-service=kdeconnect
sudo firewall-cmd --zone=ZONE --add-service=syncthing
```

> **TIPP:** Nur den tatsächlich vorhandenen Dienst freigeben. Moonlight ist normalerweise Client und benötigt keine eingehende Regel. Sunshine wird auf aktuellen Desktop-Images über Bazzite Portal als Flatpak eingerichtet; die Portal-Einrichtung und aktuelle Sunshine-Dokumentation haben Vorrang vor manuell kopierten Portlisten.

Steam Remote Play oder Sunshine diagnostisch eingrenzen:

```bash
ss -tulpn | grep -Ei 'steam|sunshine'
firewall-cmd --list-all
journalctl -b -u firewalld --no-pager
```

Erst die dabei bestätigten Ports als Runtime-Regel im korrekten LAN-Zonenprofil testen. Keine breiten Steam-Portbereiche aus alten Routeranleitungen auf dem Host öffnen.

### Logging und Verifikation

```bash
sudo firewall-cmd --set-log-denied=unicast
sudo firewall-cmd --get-log-denied
journalctl -b -u firewalld --no-pager
journalctl -k -g 'FINAL_REJECT|FINAL_DROP|firewalld' --no-pager
sudo firewall-cmd --check-config
sudo firewall-cmd --reload
```

## 4. SSH

### Diagnose und Aktivierung

```bash
rpm -q openssh-server
systemctl status sshd --no-pager
ss -ltnp | grep ':22 '
sudo sshd -t
journalctl -b -u sshd --no-pager
```

Wenn der Server im Image vorhanden ist:

```bash
sudo systemctl enable --now sshd
sudo firewall-cmd --zone=ZONE --add-service=ssh
sudo firewall-cmd --runtime-to-permanent
```

Falls `openssh-server` tatsächlich fehlt und ein Host-SSH-Dienst benötigt wird:

```bash
rpm-ostree install openssh-server
rpm-ostree status
systemctl reboot
```

Rollback: `rpm-ostree uninstall openssh-server`, neu starten und Deploymentstatus prüfen.

Rollback:

```bash
sudo firewall-cmd --zone=ZONE --remove-service=ssh
sudo firewall-cmd --runtime-to-permanent
sudo systemctl disable --now sshd
```

### Schlüssel und Verbindungen

```bash
ssh-keygen -t ed25519 -a 100
ssh-copy-id BENUTZER@HOST
ssh BENUTZER@HOST
ssh-add ~/.ssh/id_ed25519
ssh-keygen -F HOST
```

Dateien übertragen:

```bash
scp DATEI BENUTZER@HOST:ZIELPFAD
sftp BENUTZER@HOST
rsync -aHAX --info=progress2 QUELLE/ BENUTZER@HOST:ZIEL/
```

Alle Großbuchstabenwerte sind **PLATZHALTER**. Vor einem SSH-Hardening eine zweite Sitzung offen halten, `sudo sshd -t` ausführen und erst dann `sudo systemctl reload sshd` verwenden.

## 5. Samba und Netzwerkfreigaben

### Clientdiagnose

```bash
command -v smbclient
smbclient -L //SERVER -U BENUTZER
gio mount smb://SERVER/FREIGABE
```

Für gelegentliche Desktopzugriffe den Dateimanager/GIO nutzen. Dauerhafte Mounts erst nach erfolgreichem manuellen Test konfigurieren.

### Server als Container/Quadlet bevorzugen

Bazzite dokumentiert einen Samba-Quadlet als hostschonende Variante. Vor dem Aufbau:

```bash
podman version
firewall-cmd --get-services | tr ' ' '\n' | grep '^samba$'
ss -tulpn | grep -E ':(137|138|139|445)\b'
```

> **ACHTUNG:** Freigabepfade, UID/GID, SELinux-Labels und Schreibrechte vor dem Start prüfen. Keine Gastfreigabe oder SMB1 aktivieren. Passwörter nicht in Git oder lesbare Quadlet-Dateien schreiben.

Samba-Benutzer im gewählten Container mit dessen dokumentiertem `smbpasswd`-/Secret-Verfahren verwalten. Hostbenutzer und Containerbenutzer sind nicht automatisch identisch; UID/GID und Volume-Rechte explizit verifizieren.

Firewall nur im vertrauenswürdigen LAN freigeben:

```bash
sudo firewall-cmd --zone=ZONE --add-rich-rule='rule family="ipv4" source address="LAN_CIDR" service name="samba" accept'
sudo firewall-cmd --runtime-to-permanent
```

`LAN_CIDR` ist ein **PLATZHALTER**, zum Beispiel das tatsächlich geprüfte Heimnetz. Verifikation mit `smbclient`, `ss -tulpn`, Containerlogs und einem zweiten Client.

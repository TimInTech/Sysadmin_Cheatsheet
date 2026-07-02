# 05 Netzwerk, Firewall und Cluster

Netzwerk- und Firewall-Änderungen können Remote-Zugriff, Cluster-Kommunikation und VM/CT-Erreichbarkeit unterbrechen. Bei Remote-Arbeit immer Konsole/IPMI/physische Zugriffsmöglichkeit oder Rollback-Timer einplanen.

## 1. Netzwerkdiagnose auf dem Host

> HINWEIS: Diagnose. Keine Änderung.

```bash
ip address
ip route
bridge link
ss -tulpn
resolvectl status 2>/dev/null || cat /etc/resolv.conf
```

## 2. Proxmox-Netzwerkkonfiguration prüfen

> HINWEIS: Diagnose. Keine Änderung.

```bash
cat /etc/network/interfaces
ls -lah /etc/network/interfaces.d/
```

## 3. Bridges und Interfaces prüfen

> HINWEIS: Diagnose. Keine Änderung.

```bash
ip -br link
ip -br address
bridge vlan show 2>/dev/null || true
```

## 4. Netzwerkänderung absichern

> WARNUNG: Änderungen an `/etc/network/interfaces` können SSH/Web-GUI trennen. Vorher Datei sichern und Rollback bereithalten.

```bash
mkdir -p /root/pve-config-backups
cp -a /etc/network/interfaces "/root/pve-config-backups/interfaces.$(date +%Y%m%d-%H%M%S)"
ls -lah /root/pve-config-backups/interfaces.*
```

## 5. Netzwerk neu laden

> KRITISCH: Kann Verbindung trennen. Nur ausführen, wenn Konsolenzugriff oder Rollback-Timer vorhanden ist.

```bash
read -r -p "Netzwerk wirklich neu laden? Tippe RELOAD: " CONFIRM
test "$CONFIRM" = "RELOAD"
ifreload -a
ip address
ip route
```

## 6. Rollback der Netzwerkkonfiguration

> KRITISCH: Setzt `/etc/network/interfaces` auf eine Sicherung zurück. Sicherungsdatei sorgfältig auswählen.

```bash
ls -lah /root/pve-config-backups/interfaces.*
read -r -e -p "Sicherungsdatei eingeben: " BACKUP
cp -a "$BACKUP" /etc/network/interfaces
ifreload -a
ip address
ip route
```

## 7. Proxmox-Firewallstatus prüfen

> HINWEIS: Diagnose. Keine Änderung.

```bash
pve-firewall status
cat /etc/pve/firewall/cluster.fw 2>/dev/null || true
find /etc/pve -path '*firewall*' -o -name '*.fw' -print
```

## 8. Firewall-Logs prüfen

> HINWEIS: Diagnose. Keine Änderung.

```bash
journalctl -u pve-firewall -b --no-pager
journalctl -b --no-pager | grep -i firewall | tail -n 100
```

## 9. Firewall neu starten

> WARNUNG: Kann Regeln neu anwenden und Verbindungen beeinflussen. Vorher Cluster-/Node-/VM-Firewallkonfiguration prüfen.

```bash
pve-firewall status
read -r -p "Firewall neu starten? Tippe RESTART: " CONFIRM
test "$CONFIRM" = "RESTART"
systemctl restart pve-firewall
pve-firewall status
```

## 10. Clusterstatus prüfen

> HINWEIS: Diagnose. Keine Änderung.

```bash
pvecm status
pvecm nodes
systemctl status corosync pve-cluster --no-pager
journalctl -u corosync -b --no-pager | tail -n 120
```

## 11. Quorum-Probleme erkennen

> HINWEIS: Diagnose. Keine Änderung. Bei Clusterproblemen nicht blind Nodes entfernen oder Quorum erzwingen.

```bash
pvecm status
journalctl -u corosync -b --no-pager | grep -Ei 'quorum|token|ring|error|fail' | tail -n 120
```

## 12. VM/CT-Netzwerkzuordnung prüfen

> HINWEIS: Diagnose. Keine Änderung.

```bash
qm list
pct list
read -r -p "VMID oder CTID eingeben: " GUESTID
if test -f "/etc/pve/qemu-server/${GUESTID}.conf"; then
  grep -E '^net[0-9]+:' "/etc/pve/qemu-server/${GUESTID}.conf"
fi
if test -f "/etc/pve/lxc/${GUESTID}.conf"; then
  grep -E '^net[0-9]+:' "/etc/pve/lxc/${GUESTID}.conf"
fi
```

## Verifikation

Nach Netzwerk- oder Firewalländerungen:

```bash
ip route
ss -tulpn | grep -E ':22|:8006'
systemctl status pveproxy pvedaemon pve-firewall --no-pager
pve-firewall status
```

## Rollback

- Netzwerk: Sicherung aus `/root/pve-config-backups/interfaces.*` zurückkopieren und `ifreload -a` ausführen.
- Firewall: letzte bekannte funktionierende `.fw`-Konfiguration aus Backup/VCS zurückspielen.
- Cluster: keine destruktiven Clusterbefehle ohne vollständige Sicherung von `/etc/pve`, Node-Liste und Quorum-Analyse.

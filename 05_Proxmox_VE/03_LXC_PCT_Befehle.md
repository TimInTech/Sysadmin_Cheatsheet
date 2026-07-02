# 03 LXC-Container mit `pct`

`pct` verwaltet LXC-Container in Proxmox VE. Container teilen sich den Kernel des Hosts. Deshalb sind Privilegien, AppArmor, Mounts und cgroup-v2-Kompatibilität wichtig.

## 1. Container auflisten

> HINWEIS: Diagnose. Keine Änderung.

```bash
pct list
```

## 2. Status und Konfiguration prüfen

> HINWEIS: Diagnose. CTID wird interaktiv abgefragt.

```bash
read -r -p "CTID eingeben: " CTID
pct status "$CTID"
pct config "$CTID"
```

## 3. Unprivileged/Privileged prüfen

> HINWEIS: Diagnose. Privilegierte Container sind sicherheitskritischer.

```bash
read -r -p "CTID eingeben: " CTID
pct config "$CTID" | grep -E '^(unprivileged|features|lxc\.apparmor|mp[0-9]+|rootfs):'
```

## 4. Container starten

> WARNUNG: Startet einen Container. Vorher Storage, Mountpoints und Locks prüfen.

```bash
read -r -p "CTID eingeben: " CTID
pct status "$CTID"
pvesm status
pct start "$CTID"
pct status "$CTID"
```

## 5. Container sauber herunterfahren

> WARNUNG: Unterbricht Dienste im Container. Vorher Wartungsfenster prüfen.

```bash
read -r -p "CTID eingeben: " CTID
pct status "$CTID"
pct shutdown "$CTID" --timeout 120
pct status "$CTID"
```

## 6. Container erzwingen stoppen

> KRITISCH: Harter Stop kann Datenverlust im Container verursachen. Vorher Backup/Snapshot prüfen.

```bash
read -r -p "CTID eingeben: " CTID
pct status "$CTID"
read -r -p "Harten Stop wirklich ausführen? Tippe STOP: " CONFIRM
test "$CONFIRM" = "STOP"
pct stop "$CTID"
pct status "$CTID"
```

## 7. In Container-Konsole einsteigen

> HINWEIS: Interaktive Administration im Container. Keine Hostbefehle im Container erwarten.

```bash
read -r -p "CTID eingeben: " CTID
pct enter "$CTID"
```

## 8. Befehl im Container ausführen

> HINWEIS: Diagnose im Container.

```bash
read -r -p "CTID eingeben: " CTID
pct exec "$CTID" -- cat /etc/os-release
pct exec "$CTID" -- systemctl --failed
```

## 9. Container-Snapshot erstellen

> WARNUNG: Snapshot ist kein externes Backup. Vor riskanten Änderungen zusätzlich Backup prüfen.

```bash
read -r -p "CTID eingeben: " CTID
SNAPNAME="prechange-$(date +%Y%m%d-%H%M%S)"
pct status "$CTID"
pct snapshot "$CTID" "$SNAPNAME" --description "Manueller Snapshot vor Änderung $(date -Is)"
pct listsnapshot "$CTID"
```

## 10. Snapshot zurückrollen

> KRITISCH: Rollback verwirft den aktuellen Containerzustand auf den Snapshot-Stand. Vorher Daten seit Snapshot sichern.

```bash
read -r -p "CTID eingeben: " CTID
pct listsnapshot "$CTID"
read -r -p "Snapshot-Name eingeben: " SNAPNAME
read -r -p "Rollback wirklich ausführen? Tippe ROLLBACK: " CONFIRM
test "$CONFIRM" = "ROLLBACK"
pct rollback "$CTID" "$SNAPNAME"
pct status "$CTID"
```

## 11. Container-Konfiguration sichern

> HINWEIS: Sichert nur die Proxmox-Containerkonfiguration, nicht das Container-Dateisystem.

```bash
read -r -p "CTID eingeben: " CTID
mkdir -p /root/pve-config-backups
cp -a "/etc/pve/lxc/${CTID}.conf" "/root/pve-config-backups/${CTID}.conf.$(date +%Y%m%d-%H%M%S)"
ls -lah /root/pve-config-backups/
```

## 12. Typische Container-Problemstellen prüfen

> HINWEIS: Diagnose. Keine Änderung.

```bash
read -r -p "CTID eingeben: " CTID
pct config "$CTID" | grep -E '^(arch|cores|memory|swap|rootfs|mp[0-9]+|net[0-9]+|features|unprivileged):'
pct exec "$CTID" -- df -hT
pct exec "$CTID" -- ip address
pct exec "$CTID" -- ip route
```

## Verifikation

```bash
read -r -p "CTID eingeben: " CTID
pct status "$CTID"
pct config "$CTID" | sed -n '1,120p'
```

## Rollback

- Bei Konfigurationsänderungen: Sicherung aus `/root/pve-config-backups/` verwenden.
- Bei Paket-/Dienständerungen im Container: Container-Snapshot oder Backup zurückspielen.
- Bei Mountpoint-Problemen: Container gestoppt lassen und Host-Storage prüfen.

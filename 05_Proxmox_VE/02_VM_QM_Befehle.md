# 02 Virtuelle Maschinen mit `qm`

`qm` verwaltet QEMU/KVM-VMs in Proxmox VE. Erst VMID und Status prüfen, dann Änderungen ausführen.

## 1. VMs auflisten

> HINWEIS: Diagnose. Keine Änderung.

```bash
qm list
```

## 2. Status und Konfiguration einer VM prüfen

> HINWEIS: Diagnose. Die VMID wird interaktiv abgefragt, damit kein Platzhalter blind kopiert wird.

```bash
read -r -p "VMID eingeben: " VMID
qm status "$VMID"
qm config "$VMID"
```

## 3. VM-Logs und Task-Historie prüfen

> HINWEIS: Diagnose. Keine Änderung.

```bash
read -r -p "VMID eingeben: " VMID
qm status "$VMID"
journalctl -b --no-pager | grep -E "VM ${VMID}|qm\[|qemu" | tail -n 80
find /var/log/pve/tasks -type f -mtime -7 -print0 | xargs -0 grep -h "VM ${VMID}\|qm${VMID}\|${VMID}" 2>/dev/null | tail -n 80
```

## 4. VM sauber starten

> WARNUNG: Startet eine VM. Vorher Ressourcen, Storage und Locks prüfen.

```bash
read -r -p "VMID eingeben: " VMID
qm status "$VMID"
pvesm status
qm start "$VMID"
qm status "$VMID"
```

## 5. VM sauber herunterfahren

> WARNUNG: Fährt eine VM über ACPI/Guest-Agent sauber herunter. Falls der Gast nicht reagiert, nicht sofort `stop` verwenden; erst Konsole, Logs und Gastzustand prüfen.

```bash
read -r -p "VMID eingeben: " VMID
qm status "$VMID"
qm shutdown "$VMID" --timeout 120
qm status "$VMID"
```

## 6. VM erzwingen stoppen

> KRITISCH: `qm stop` entspricht einem harten Ausschalten. Datenverlust im Gast ist möglich. Vorher prüfen, ob ein Backup oder Snapshot vorhanden ist.

```bash
read -r -p "VMID eingeben: " VMID
qm status "$VMID"
read -r -p "Harten Stop wirklich ausführen? Tippe STOP: " CONFIRM
test "$CONFIRM" = "STOP"
qm stop "$VMID"
qm status "$VMID"
```

## 7. VM neu starten

> WARNUNG: Neustart unterbricht Dienste im Gast. Vorher Wartungsfenster prüfen.

```bash
read -r -p "VMID eingeben: " VMID
qm status "$VMID"
qm reboot "$VMID" --timeout 120
qm status "$VMID"
```

## 8. Snapshot erstellen

> WARNUNG: Snapshot ist kein Backup. Vor größeren Änderungen trotzdem externes Backup prüfen.

```bash
read -r -p "VMID eingeben: " VMID
SNAPNAME="prechange-$(date +%Y%m%d-%H%M%S)"
qm status "$VMID"
qm snapshot "$VMID" "$SNAPNAME" --description "Manueller Snapshot vor Änderung $(date -Is)"
qm listsnapshot "$VMID"
```

## 9. Snapshot zurückrollen

> KRITISCH: Rollback verwirft den aktuellen Zustand der VM auf den Snapshot-Stand. Vorher prüfen, ob Daten seit dem Snapshot gesichert werden müssen.

```bash
read -r -p "VMID eingeben: " VMID
qm listsnapshot "$VMID"
read -r -p "Snapshot-Name eingeben: " SNAPNAME
read -r -p "Rollback wirklich ausführen? Tippe ROLLBACK: " CONFIRM
test "$CONFIRM" = "ROLLBACK"
qm rollback "$VMID" "$SNAPNAME"
qm status "$VMID"
```

## 10. VM-Konfiguration vor Änderungen sichern

> HINWEIS: Diagnose/Backup der Konfigurationsdatei. Keine Änderung an der VM.

```bash
read -r -p "VMID eingeben: " VMID
mkdir -p /root/pve-config-backups
cp -a "/etc/pve/qemu-server/${VMID}.conf" "/root/pve-config-backups/${VMID}.conf.$(date +%Y%m%d-%H%M%S)"
ls -lah /root/pve-config-backups/
```

## 11. Bootreihenfolge und Disks prüfen

> HINWEIS: Diagnose. Keine Änderung.

```bash
read -r -p "VMID eingeben: " VMID
qm config "$VMID" | grep -E '^(boot|bootdisk|scsi|virtio|ide|sata|efidisk|tpmstate|bios|machine):'
```

## 12. Guest Agent prüfen

> HINWEIS: Diagnose. Funktioniert nur, wenn der QEMU Guest Agent im Gast installiert und in Proxmox aktiviert ist.

```bash
read -r -p "VMID eingeben: " VMID
qm agent "$VMID" ping
qm agent "$VMID" network-get-interfaces
```

## Verifikation

Nach jeder Aktion:

```bash
read -r -p "VMID eingeben: " VMID
qm status "$VMID"
qm config "$VMID" | sed -n '1,80p'
```

## Rollback

- Bei Konfigurationsänderungen: gesicherte Datei aus `/root/pve-config-backups/` prüfen und gezielt zurückkopieren.
- Bei Gaständerungen: Snapshot-Rollback nur nach Datenprüfung.
- Bei Start-/Stop-Problemen: Logs aus `journalctl`, Task-Logs und Konsole prüfen, nicht blind mehrfach starten/stoppen.

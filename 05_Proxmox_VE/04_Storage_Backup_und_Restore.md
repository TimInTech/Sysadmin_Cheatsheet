# 04 Storage, Backup und Restore

Storage- und Backup-Befehle können Datenverlust verursachen. Erst Storage-Typ, Inhalt, freien Platz und Ziel prüfen.

## 1. Storage-Status prüfen

> HINWEIS: Diagnose. Keine Änderung.

```bash
pvesm status
pvesm list local
df -hT
lsblk -f
findmnt
```

## 2. Storage-Konfiguration lesen

> HINWEIS: Diagnose. Keine Änderung.

```bash
cat /etc/pve/storage.cfg
```

## 3. VM- und CT-Disks finden

> HINWEIS: Diagnose. Keine Änderung.

```bash
qm list
pct list
pvesm list local
```

## 4. Backups auflisten

> HINWEIS: Diagnose. Keine Änderung. Falls ein anderer Backup-Storage verwendet wird, zuerst mit `pvesm status` den Namen ermitteln.

```bash
pvesm status
find /var/lib/vz/dump -maxdepth 1 -type f -name 'vzdump-*' -printf '%TY-%Tm-%Td %TH:%TM %p
' 2>/dev/null | sort
```

## 5. Einzelnes Backup erstellen

> WARNUNG: Backup erzeugt Last auf Storage, CPU und Gast. Vorher freien Platz prüfen.

```bash
pvesm status
read -r -p "VMID/CTID eingeben: " GUESTID
read -r -p "Backup-Storage aus pvesm status eingeben: " STORAGE
vzdump "$GUESTID" --storage "$STORAGE" --mode snapshot --compress zstd
```

## 6. Backup verifizieren

> HINWEIS: Prüft, ob Backup-Dateien sichtbar sind. Bei Proxmox Backup Server zusätzlich die PBS-Verifikation im PBS verwenden.

```bash
pvesm status
find /var/lib/vz/dump -maxdepth 1 -type f -name 'vzdump-*' -printf '%TY-%Tm-%Td %TH:%TM %s %p
' 2>/dev/null | sort | tail -n 20
```

## 7. Backup-Job-Konfiguration prüfen

> HINWEIS: Diagnose. Keine Änderung.

```bash
cat /etc/pve/jobs.cfg 2>/dev/null || true
cat /etc/pve/vzdump.cron 2>/dev/null || true
```

## 8. Restore vorbereiten

> KRITISCH: Restore kann vorhandene VMs/Container überschreiben, wenn dieselbe ID verwendet wird. Vorher Ziel-ID, Storage und Backup-Datei prüfen.

```bash
pvesm status
qm list
pct list
find /var/lib/vz/dump -maxdepth 1 -type f -name 'vzdump-*' -printf '%TY-%Tm-%Td %TH:%TM %p
' 2>/dev/null | sort | tail -n 20
```

## 9. Freie Ziel-ID für Restore wählen

> HINWEIS: Diagnose. Keine Änderung.

```bash
pvesh get /cluster/nextid
```

## 10. VM-Restore mit `qmrestore`

> KRITISCH: Restore legt eine VM aus einem Backup an. Nicht auf eine bestehende produktive ID wiederherstellen, außer das ist bewusst geplant und abgesichert.

```bash
pvesh get /cluster/nextid
read -r -p "Neue freie Ziel-VMID eingeben: " NEWID
read -r -e -p "Pfad zur vzdump-qemu Backup-Datei eingeben: " BACKUP
read -r -p "Ziel-Storage aus pvesm status eingeben: " STORAGE
read -r -p "Restore wirklich starten? Tippe RESTORE: " CONFIRM
test "$CONFIRM" = "RESTORE"
qmrestore "$BACKUP" "$NEWID" --storage "$STORAGE" --unique true
qm status "$NEWID"
```

## 11. CT-Restore mit `pct restore`

> KRITISCH: Restore legt einen Container aus einem Backup an. Nicht auf eine bestehende produktive ID wiederherstellen, außer das ist bewusst geplant und abgesichert.

```bash
pvesh get /cluster/nextid
read -r -p "Neue freie Ziel-CTID eingeben: " NEWID
read -r -e -p "Pfad zur vzdump-lxc Backup-Datei eingeben: " BACKUP
read -r -p "Ziel-Storage aus pvesm status eingeben: " STORAGE
read -r -p "Restore wirklich starten? Tippe RESTORE: " CONFIRM
test "$CONFIRM" = "RESTORE"
pct restore "$NEWID" "$BACKUP" --storage "$STORAGE"
pct status "$NEWID"
```

## 12. Storage-Cleanup nur vorbereiten

> KRITISCH: Keine automatischen Löschbefehle ohne manuelle Prüfung. Erst große Dateien und alte Backups anzeigen.

```bash
df -hT
find /var/lib/vz/dump -maxdepth 1 -type f -name 'vzdump-*' -printf '%TY-%Tm-%Td %TH:%TM %s %p
' 2>/dev/null | sort
```

## Verifikation

```bash
pvesm status
qm list
pct list
```

## Rollback

- Bei fehlgeschlagenem Restore: neu angelegte Test-VM/CT erst prüfen, dann gezielt über GUI oder CLI entfernen.
- Bei Backup-Problemen: kein altes Backup löschen, bevor ein neues erfolgreich erstellt und testweise wiederhergestellt wurde.
- Bei Storage-Änderungen: `/etc/pve/storage.cfg` vorher sichern und Änderung dokumentieren.

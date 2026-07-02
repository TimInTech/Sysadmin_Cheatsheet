# 01 Status, Versionen und Logs

Diese Datei dient der Erstdiagnose eines Proxmox-VE-Hosts. Keine Änderungen ausführen, bevor Versionen, Dienste, Clusterstatus, Storage und Logs geprüft wurden.

## 1. System- und Proxmox-Version prüfen

> HINWEIS: Diagnose. Keine Änderung am System.

```bash
pveversion -v
uname -a
cat /etc/os-release
```

## 2. Repositories und Paketstatus prüfen

> HINWEIS: Diagnose. Keine Änderung am System.

```bash
apt policy proxmox-ve pve-manager pve-kernel-6* pve-kernel-*
apt list --upgradable 2>/dev/null
grep -RhsE '^(deb|Types:|URIs:|Suites:|Components:)' /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources 2>/dev/null
```

## 3. Dienste und fehlgeschlagene Units prüfen

> HINWEIS: Diagnose. Keine Änderung am System.

```bash
systemctl --failed
systemctl status pveproxy pvedaemon pvestatd pve-cluster corosync --no-pager
```

## 4. Fehler seit dem letzten Boot prüfen

> HINWEIS: Diagnose. Keine Änderung am System.

```bash
journalctl -p err -b --no-pager
dmesg -T --level=err,warn
```

## 5. Proxmox-Tasks und Locks prüfen

> HINWEIS: Diagnose. Keine Änderung am System.

```bash
ls -lah /var/log/pve/tasks
find /var/log/pve/tasks -type f -mtime -2 -print | sort | tail -n 30
find /run/lock -maxdepth 2 -type f -name '*lock*' -print
```

## 6. Storage-Status prüfen

> HINWEIS: Diagnose. Keine Änderung am System.

```bash
pvesm status
df -hT
lsblk -f
findmnt
```

## 7. Clusterstatus prüfen

> HINWEIS: Diagnose. Bei Einzelnode kann `pvecm status` ohne Cluster entsprechend Fehler oder Einzelnode-Status zeigen.

```bash
pvecm status
pvecm nodes
```

## 8. Gastübersicht prüfen

> HINWEIS: Diagnose. Keine Änderung an VMs oder Containern.

```bash
qm list
pct list
```

## 9. Schneller Health-Block für Support-Ausgaben

> HINWEIS: Diagnose. Dieser Block sammelt Statusausgaben ohne Secrets. Trotzdem vor Veröffentlichung prüfen.

```bash
{
  echo "== pveversion =="
  pveversion -v
  echo
  echo "== failed units =="
  systemctl --failed
  echo
  echo "== storage =="
  pvesm status
  echo
  echo "== guests =="
  qm list
  pct list
  echo
  echo "== cluster =="
  pvecm status
  echo
  echo "== recent errors =="
  journalctl -p err -b --no-pager | tail -n 80
} | tee /tmp/proxmox-health.txt
```

## Verifikation

```bash
test -s /tmp/proxmox-health.txt && tail -n 20 /tmp/proxmox-health.txt
```

## Rollback

Keine Änderung erfolgt. Die Datei `/tmp/proxmox-health.txt` kann gelöscht werden:

```bash
rm -f /tmp/proxmox-health.txt
```

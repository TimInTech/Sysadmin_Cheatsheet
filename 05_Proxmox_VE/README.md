# 05 Proxmox VE

Rubrik für Proxmox-VE-Hosts mit Diagnose-first-Aufbau. Ziel ist nicht, möglichst viele riskante Befehle zu sammeln, sondern reproduzierbare Admin-Schritte mit Prüfung, Warnung, Verifikation und Rollback zu dokumentieren.

## Dateien

- [01 Status, Versionen und Logs](01_Status_Versionen_und_Logs.md)
- [02 Virtuelle Maschinen mit qm](02_VM_QM_Befehle.md)
- [03 LXC-Container mit pct](03_LXC_PCT_Befehle.md)
- [04 Storage, Backup und Restore](04_Storage_Backup_und_Restore.md)
- [05 Netzwerk, Firewall und Cluster](05_Netzwerk_Firewall_und_Cluster.md)

## Grundregel

1. Erst Hostzustand prüfen.
2. Dann Ziel ermitteln: Node, VMID, CTID, Storage, Bridge, Interface.
3. Danach Änderung ausführen.
4. Ergebnis prüfen.
5. Rollback-Pfad dokumentieren.

## Warnstufen

> HINWEIS: Reiner Diagnosebefehl. Keine Änderung am System.

> WARNUNG: Änderung an laufenden Diensten, VMs, Containern, Netzwerk, Storage oder Firewall. Vorher Wartungsfenster, Backup oder Snapshot prüfen.

> KRITISCH: Potenziell destruktiv. Vorher Backup/Snapshot/Image erstellen und Ziel eindeutig prüfen. Nicht auf Produktivsystemen ohne Rollback ausführen.

## Quellen

- Proxmox VE Dokumentation: https://pve.proxmox.com/pve-docs/
- qm Manual: https://pve.proxmox.com/pve-docs/qm.1.html
- pct Manual: https://pve.proxmox.com/pve-docs/pct.1.html
- pvesm Manual: https://pve.proxmox.com/pve-docs/pvesm.1.html
- vzdump Manual: https://pve.proxmox.com/pve-docs/vzdump.1.html
- pvecm Manual: https://pve.proxmox.com/pve-docs/pvecm.1.html
- Proxmox VE Firewall: https://pve.proxmox.com/pve-docs/chapter-pve-firewall.html

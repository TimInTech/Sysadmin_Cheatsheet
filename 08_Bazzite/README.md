# Bazzite Sysadmin Cheatsheet

Praxisorientierte Administration für aktuelle Bazzite-Systeme auf Basis von Fedora Atomic Desktop und Universal Blue. Die Sammlung trennt bewusst Host, Flatpak, Homebrew und Container: klassische Fedora-Anleitungen mit `sudo dnf install` sind auf dem Bazzite-Host nicht der Standardweg.

> **INFO:** Bazzite ist image-basiert, aber nicht absolut unveränderlich. `/usr` kommt aus einem signierten OCI-Systemimage; `/etc` und `/var` bleiben beschreibbar. Systemänderungen werden normalerweise als neues Deployment vorbereitet und nach einem Neustart aktiv.

> **ACHTUNG:** Vor Rebase, Rollback, Layer-Reset, Firewall-, Mount- oder Storage-Änderungen zuerst Status, Ziel und Backup prüfen. Ein OSTree-Rollback schützt keine persönlichen Dateien.

## Inhaltsverzeichnis

1. [Grundlagen und Erste Schritte](01_Grundlagen_und_Erste_Schritte.md)
2. [Updates, Deployments, Rebase und Recovery](02_Updates_Deployments_Rebase_Recovery.md)
3. [Software, Flatpak, Homebrew und Container](03_Software_Flatpak_Homebrew_Container.md)
4. [Netzwerk, Firewall, SSH und Samba](04_Netzwerk_Firewall_SSH_Samba.md)
5. [systemd, Logs, Wartung und Performance](05_Systemd_Logs_Wartung_Performance.md)
6. [Datenträger, Btrfs und Backups](06_Datentraeger_Btrfs_Backups.md)
7. [Hardware, Gaming, Audio, Bluetooth und Sicherheit](07_Hardware_Gaming_Audio_Sicherheit.md)
8. [Quick Commands und Troubleshooting](08_Quick_Commands_und_Troubleshooting.md)
9. [Quellen und Kompatibilitätsrahmen](09_Quellen_und_Kompatibilitaet.md)

## Software richtig einordnen

| Bedarf | Empfohlener Ort | Beispiel | Host-Neustart |
|---|---|---|---|
| Grafische Desktop-App | Bazaar/Flatpak | Firefox, Discord, Pika Backup | Nein |
| CLI/TUI-Programm | Homebrew | `jq`, `yt-dlp`, `restic` | Nein |
| Paket aus `apt`, `dnf`, `pacman` | Distrobox | Entwicklerwerkzeuge, `.deb`, `.rpm` | Nein |
| Dauerhafter Serverdienst | Rootless Podman + Quadlet | Webdienst, Syncthing-Container | Nein |
| Portable GUI-Anwendung | AppImage/Gear Lever | Einzelne Hersteller-App | Nein |
| Treiber, Kernelmodul, hostnaher Dienst | `rpm-ostree` als letzte Wahl | Spezielle Hardwareintegration | Meist ja |
| Eigene einzelne Binärdatei | `~/.local/bin` | Selbst gebautes Tool | Nein |

> **TIPP:** Reihenfolge der Bazzite-Dokumentation: Bazzite Portal/`ujust`, Flatpak, Homebrew, Container, AppImage und erst zuletzt Package Layering.

## Robuster Diagnoseablauf

1. Zustand ohne Änderung erfassen.
2. Host- oder Containerkontext eindeutig bestimmen.
3. Logs und betroffene Versionen sichern.
4. Die kleinste reversible Änderung durchführen.
5. Ergebnis und nächsten Boot prüfen.
6. Bei Verschlechterung den dokumentierten Rollback verwenden.

```bash
cat /etc/os-release
uname -r
rpm-ostree status -v
bootc status 2>/dev/null || true
systemctl --failed
journalctl -b -p warning --no-pager
df -hT
```

## Sicherheitskennzeichnungen

> **INFO:** Hintergrund oder reine Diagnose.

> **TIPP:** Bevorzugtes, risikoarmes Vorgehen.

> **ACHTUNG:** Ändert Konfiguration, Dienste oder ein zukünftiges Deployment.

> **WARNUNG:** Potenziell destruktiv oder mit Datenverlust-/Bootrisiko. Vorher Backup oder Snapshot erstellen und das Ziel prüfen.

## Wichtige Abgrenzungen

- `ujust update` ist der von Bazzite dokumentierte manuelle Gesamt-Updateweg.
- `rpm-ostree upgrade` aktualisiert das Host-Deployment, ersetzt aber nicht alle zusätzlichen Update-Schritte von `ujust update`.
- `bootc` ist für die image-basierte Systemverwaltung relevant. Auf Bazzite dennoch keine generischen `bootc upgrade`-Abläufe anstelle des Bazzite-Updaters erzwingen.
- `dnf`/`dnf5` im Host ist nicht der normale Installationsweg. In einer Distrobox ist es dagegen korrekt.
- `podman-compose` oder `podman compose` können Compose-Dateien ausführen; für dauerhaft verwaltete Dienste empfiehlt Bazzite Quadlet.
- Ein früheres Deployment setzt das Betriebssystem zurück, nicht `/home`, Flatpak-App-Daten oder Container-Volumes.

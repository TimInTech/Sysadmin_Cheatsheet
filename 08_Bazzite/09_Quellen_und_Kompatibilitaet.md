# 09 Quellen und Kompatibilitätsrahmen

Stand der fachlichen Prüfung: **August 2026**. Bazzite entwickelt sich schnell; vor Rebases, Imagewechseln und Hardwareeingriffen die aktuelle Dokumentation erneut prüfen.

## 1. Priorisierte offizielle Quellen

### Bazzite und Universal Blue

- [Bazzite-Dokumentation](https://docs.bazzite.gg/) – aktueller Einstieg und Varianten.
- [Updates, Rollbacks und Rebases](https://docs.bazzite.gg/Installing_and_Managing_Software/Updates_Rollbacks_and_Rebasing/) – unterstützte Systempfade.
- [Update Guide](https://docs.bazzite.gg/Installing_and_Managing_Software/Updates_Rollbacks_and_Rebasing/updating_guide/) – `ujust update` und Neustartverhalten.
- [Rollbacks](https://docs.bazzite.gg/Installing_and_Managing_Software/Updates_Rollbacks_and_Rebasing/rolling_back_system_updates/) – GRUB, rpm-ostree und Pins.
- [Bazzite Rollback Helper](https://docs.bazzite.gg/Installing_and_Managing_Software/Updates_Rollbacks_and_Rebasing/bazzite_rollback_helper/) – `brh` und Imagehistorie.
- [Rebase Guide](https://docs.bazzite.gg/Installing_and_Managing_Software/Updates_Rollbacks_and_Rebasing/rebase_guide/) – Kanäle, Images und Grenzen.
- [Software installieren](https://docs.bazzite.gg/Installing_and_Managing_Software/software-intro/) – Flatpak/Brew/Container/Layering.
- [Package Layering](https://docs.bazzite.gg/Installing_and_Managing_Software/rpm-ostree/) – rpm-ostree-Nutzung und Risiken.
- [Distrobox](https://docs.bazzite.gg/Installing_and_Managing_Software/Distrobox/) und [Quadlet](https://docs.bazzite.gg/Installing_and_Managing_Software/Quadlet/) – Containerintegration.
- [Sunshine auf Bazzite](https://docs.bazzite.gg/Advanced/sunshine/) – aktueller Portal-/Flatpak-Weg und Deck-Abweichungen.
- [Bazzite-Quellrepository](https://github.com/ublue-os/bazzite) – Imagebau, ujust und Snapper-Integration.

### Basistechnik und Werkzeuge

- [rpm-ostree Administrator Handbook](https://coreos.github.io/rpm-ostree/administrator-handbook/) und [OCI-Container](https://coreos.github.io/rpm-ostree/container/).
- [bootc-Dokumentation](https://bootc-dev.github.io/bootc/) und [Fedora Atomic Desktops](https://fedoraproject.org/atomic-desktops/).
- [Flatpak-Anwendung](https://docs.flatpak.org/en/latest/using-flatpak.html) und [Befehlsreferenz](https://docs.flatpak.org/en/latest/flatpak-command-reference.html).
- [Distrobox](https://distrobox.it/), [Podman](https://docs.podman.io/) und [Podman Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html).
- [firewalld](https://firewalld.org/documentation/), [fwupdmgr](https://fwupd.github.io/libfwupdplugin/fwupdmgr.html), [Btrfs](https://btrfs.readthedocs.io/) und [systemd](https://www.freedesktop.org/software/systemd/man/latest/).
- [Bazzite Gaming Issues](https://docs.bazzite.gg/Gaming/Common_gaming_issues/), [Startoptionen](https://docs.bazzite.gg/Gaming/launch-options-env-variables/) und [Hardwarekompatibilität](https://docs.bazzite.gg/Gaming/Hardware_compatibility_for_gaming/).

## 2. Bewusste technische Entscheidungen

- Kein Host-`dnf install`: Flatpak, Brew, Distrobox und Quadlet haben Vorrang; Layering ist letzte Wahl.
- `ujust update` vor generischem `bootc upgrade`: Der Bazzite-Wrapper deckt zusätzliche Softwarekanäle ab.
- firewalld statt parallelem direktem nftables: Zonen, Services und Runtime/Permanent bleiben konsistent.
- Quadlet vor selbst generierten Podman-systemd-Units: deklarativ und aktuell empfohlen.
- Snapper über `ujust configure-snapshots`: Bazzite-eigene Einrichtung für `/var/home`.
- Kein Timeshift-Standard: Root-Restore passt nicht zuverlässig zum OSTree-/OCI-Modell.
- Kein generisches GRUB-/Dracut-Repair: offizielles Bazzite-Live-Werkzeug bevorzugen.
- Keine ungezielten Prune-/Repair-Befehle: erst Inventar und Backup, dann komponentenspezifisch handeln.

## 3. Lokal validieren

```bash
command -v ujust bazzite-rollback-helper rpm-ostree bootc flatpak brew distrobox podman
ujust --list | less
rpm-ostree --version
bootc --version 2>/dev/null || true
flatpak --version
podman version
```

Wenn ein Befehl fehlt, nicht automatisch aus einer beliebigen Quelle nachinstallieren. Zuerst Bazzite-Version, Imagevariante und aktuelle offizielle Dokumentation abgleichen.

# 02 Updates, Deployments, Rebase und Recovery

## 1. Update, Upgrade, Rebase und Rollback

| Begriff | Bedeutung auf Bazzite |
|---|---|
| Update/Upgrade | Neues Image und zusätzliche Softwareaktualisierungen beziehen; Aktivierung des Host-Deployments beim Neustart |
| Rebase | Auf ein anderes Bazzite-Image oder einen anderen Kanal wechseln |
| Rollback | Vorheriges Deployment als nächsten Standardboot verwenden |
| Pin | Deployment vor automatischer Bereinigung schützen |

## 2. System sicher aktualisieren

### Vorprüfung ohne Änderung

```bash
rpm-ostree status -v
df -h /
findmnt /
systemctl --failed
bootc upgrade --check 2>/dev/null || true
flatpak remote-ls --updates 2>/dev/null || true
fwupdmgr get-updates 2>/dev/null || true
```

> **INFO:** Bazzite verlangt laut aktueller Update-Dokumentation mindestens 3 % freien Speicher auf dem Systemlaufwerk. `bootc upgrade --check` ist nur eine Metadatenprüfung; für den eigentlichen Bazzite-Gesamtupdateweg `ujust update` verwenden.

### Empfohlener manueller Gesamtupdateweg

```bash
ujust update
rpm-ostree status -v
systemctl reboot
```

Nach dem Neustart verifizieren:

```bash
rpm-ostree status -v
uname -r
systemctl --failed
journalctl -b -p err --no-pager
```

Desktop-Images laden Updates normalerweise automatisch im Hintergrund. Bazzite-Deck aktualisiert über `Steam-Menü > Einstellungen > System`. `ujust update` funktioniert auf beiden Varianten.

### Nur Host-Deployment mit rpm-ostree

```bash
rpm-ostree upgrade --check
rpm-ostree upgrade
rpm-ostree status
systemctl reboot
```

> **TIPP:** `rpm-ostree upgrade` ist technisch unterstützt, aktualisiert aber nicht automatisch jeden von `ujust update` abgedeckten Softwarekanal.

### Einzelne Ökosysteme

```bash
flatpak update
brew update && brew upgrade && brew cleanup
distrobox upgrade --all
podman auto-update --dry-run
podman auto-update
fwupdmgr refresh
fwupdmgr get-updates
sudo fwupdmgr update
```

> **ACHTUNG:** Firmwareupdates können einen Neustart verlangen. Gerät am Netzteil betreiben und den Vorgang nicht unterbrechen. `podman auto-update` wirkt nur auf entsprechend gelabelte Container/Quadlets.

## 3. Deployments und Pins

```bash
rpm-ostree status
rpm-ostree status -v
rpm-ostree status --json
sudo ostree admin status
```

Aktuelles Deployment schützen:

```bash
sudo ostree admin pin 0
rpm-ostree status -v
```

Vorheriges Deployment schützen:

```bash
sudo ostree admin pin 1
rpm-ostree status -v
```

Pin entfernen:

```bash
sudo ostree admin pin --unpin INDEX
rpm-ostree status -v
```

`INDEX` ist ein **PLATZHALTER** aus `rpm-ostree status -v`.

## 4. Rollback

### Bevorzugter Bazzite-Assistent

```bash
bazzite-rollback-helper current
bazzite-rollback-helper list
bazzite-rollback-helper rollback
systemctl reboot
```

Kurzalias: `brh`.

### Auf das direkte vorherige Deployment

```bash
rpm-ostree status -v
rpm-ostree rollback
rpm-ostree status -v
systemctl reboot
```

Rollback des Rollbacks: denselben `rpm-ostree rollback`-Ablauf erneut ausführen oder wieder auf `stable` wechseln.

### Vor dem Boot

Im GRUB-Menü `:1` für das vorherige Deployment statt `:0` wählen. Das ist zunächst nur eine Bootauswahl; danach Status und Fehler prüfen.

## 5. Rebase

> **WARNUNG:** Vor einem Rebase persönliche Daten extern sichern, aktuelles Deployment pinnen, freien Speicher prüfen und die exakte Imagefamilie verifizieren. Ein Wechsel zwischen KDE und GNOME per Rebase wird von Bazzite nicht unterstützt; dafür sichern und neu installieren.

### Vorbereitung

```bash
rpm-ostree status -v
bazzite-rollback-helper current
df -h /
sudo ostree admin pin 0
```

### Mit dem Bazzite Rollback Helper

```bash
bazzite-rollback-helper list
bazzite-rollback-helper rebase IMAGE_ODER_KANAL
rpm-ostree status -v
systemctl reboot
```

`IMAGE_ODER_KANAL` ist ein **PLATZHALTER**, der exakt aus `bazzite-rollback-helper list` übernommen wird. Rückkehr zu regulären Updates:

```bash
bazzite-rollback-helper rebase stable
systemctl reboot
```

### Direkter Rebase für erfahrene Administratoren

```bash
rpm-ostree status -v
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/IMAGE:KANAL
rpm-ostree status -v
systemctl reboot
```

`IMAGE` und `KANAL` sind **PLATZHALTER**. Endnutzerkanäle sind `stable` und `testing`; `unstable` ist für Mitwirkende. AMD/Intel-, NVIDIA-, Desktop- und Deck-Varianten nicht raten, sondern mit Image Picker, `brh list` und aktueller Imagequelle abgleichen.

> **ACHTUNG:** Ein datiertes altes Image erhält keine Sicherheitsupdates. Nach Ende der Fehleranalyse wieder auf `stable` wechseln.

## 6. rpm-ostree Package Layering

```bash
rpm-ostree status -v
rpm-ostree search PAKET
rpm-ostree install PAKET
rpm-ostree status
systemctl reboot
```

Entfernen:

```bash
rpm-ostree uninstall PAKET
rpm-ostree status
systemctl reboot
```

`PAKET` ist ein **PLATZHALTER**. Layer nur für hostnahe Komponenten verwenden, die nicht als Flatpak, Brew-Paket oder Container funktionieren.

Alle Layer entfernen:

> **WARNUNG:** `rpm-ostree reset` entfernt alle Layer- und Override-Anforderungen aus dem nächsten Deployment. Vorher `rpm-ostree status -v` in eine Datei sichern, persönliche Daten extern sichern und ein funktionierendes Deployment pinnen.

```bash
rpm-ostree status -v | tee ~/rpm-ostree-before-reset.txt
sudo ostree admin pin 0
rpm-ostree reset
rpm-ostree status -v
systemctl reboot
```

Rollback ist das gepinnte vorherige Deployment oder das gezielte erneute Layern der in `~/rpm-ostree-before-reset.txt` dokumentierten Pakete.

## 7. Bazzite reparieren / Recovery

### System bootet noch

1. Zustand und Logs erfassen.
2. Layer/Overrides als Ursache prüfen.
3. Bei Update-Regression vorheriges Deployment testen.
4. Erst danach Layer entfernen oder Reset ausführen.

```bash
rpm-ostree status -v
systemctl --failed
journalctl -b -p err --no-pager
journalctl -b -u rpm-ostreed --no-pager
bootc status 2>/dev/null || true
```

Fehlerhafte einzelne Layer entfernen:

```bash
rpm-ostree uninstall PAKET
systemctl reboot
```

### System bootet nicht

1. Im GRUB-Menü das vorherige Deployment `:1` starten.
2. Wenn das gelingt, `rpm-ostree status -v` und Logs des fehlerhaften vorherigen Boots lesen.
3. Wenn kein Deployment startet, Bazzite-Live-ISO booten.
4. Für Bootloaderprobleme das offizielle **Bazzite Bootloader Restoration Tool** des Live-Systems verwenden.
5. Vor manuellen Mount-/Chroot-Schritten Partitionen mit `lsblk -f` und `blkid` identifizieren und Daten sichern.

Vorheriger Boot:

```bash
journalctl --list-boots
journalctl -b -1 -p warning --no-pager
journalctl -b -1 -k --no-pager
```

> **WARNUNG:** Kein generisches `grub-install`, `grub2-mkconfig`, `dracut -f`, `ostree admin cleanup` oder Dateisystem-Repair ungeprüft aus klassischen Fedora-Anleitungen übernehmen. Bazzite nutzt image- und variantenabhängige Bootpfade.


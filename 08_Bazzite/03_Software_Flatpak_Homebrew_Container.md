# 03 Software, Flatpak, Homebrew und Container

## 1. Flatpak

### Anzeigen, suchen und installieren

```bash
flatpak remotes --show-details
flatpak search SUCHBEGRIFF
flatpak install flathub APP_ID
flatpak list --app --columns=application,name,version,installation
flatpak info APP_ID
flatpak run APP_ID
```

Flathub ist auf Bazzite normalerweise vorkonfiguriert. Nur wenn die Diagnose kein `flathub` zeigt:

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remotes --show-details
```

`SUCHBEGRIFF` und `APP_ID` sind **PLATZHALTER**.

### Aktualisieren und entfernen

```bash
flatpak remote-ls --updates
flatpak update
flatpak uninstall APP_ID
flatpak uninstall --unused
```

> **ACHTUNG:** `flatpak uninstall --unused` entfernt nur nicht mehr benötigte Runtimes/Extensions. Die angebotene Liste vor Bestätigung lesen.

### Berechtigungen und Overrides

```bash
flatpak info --show-permissions APP_ID
flatpak override --user --show APP_ID
flatpak permission-show APP_ID
flatpak override --user --filesystem=PFAD APP_ID
flatpak override --user --nofilesystem=PFAD APP_ID
flatpak override --user --reset APP_ID
flatpak permission-reset APP_ID
```

`PFAD` ist ein **PLATZHALTER**. Möglichst Portale verwenden und keine pauschalen `--filesystem=host`-Freigaben setzen.

### Reparatur

```bash
flatpak history
flatpak repair --user
sudo flatpak repair --system
flatpak update
```

Rollback: App-Overrides mit `flatpak override --user --reset APP_ID` entfernen. Ein Flatpak-Downgrade erfolgt komfortabel über Warehouse; vorab App-Daten sichern.

## 2. Homebrew

```bash
brew --version
brew doctor
brew search PAKET
brew info PAKET
brew install PAKET
brew list --versions
brew update
brew outdated
brew upgrade
brew cleanup -n
brew cleanup
```

> **TIPP:** Brew für CLI/TUI-Werkzeuge verwenden. Host-Daemons, Kernelmodule und privilegierte Systemintegration gehören nicht in Brew.

Entfernen und prüfen:

```bash
brew uninstall PAKET
brew autoremove
brew doctor
```

## 3. Distrobox

Distrobox-Container teilen standardmäßig Home, Display, Audio und Geräteintegration mit dem Host. Sie sind keine Sicherheitsgrenze wie eine VM und sollten reproduzierbar/ersetzbar bleiben.

### Erstellen, betreten, verlassen

```bash
distrobox create --name fedora-toolbox --image registry.fedoraproject.org/fedora:latest
distrobox create --name ubuntu-toolbox --image docker.io/library/ubuntu:latest
distrobox create --name debian-toolbox --image docker.io/library/debian:stable
distrobox create --name arch-toolbox --image docker.io/library/archlinux:latest
distrobox enter fedora-toolbox
exit
```

Für reproduzierbare Arbeitsumgebungen konkrete Image-Tags statt `latest` verwenden.

### Anzeigen, aktualisieren, stoppen, löschen

```bash
distrobox list
distrobox upgrade --all
distrobox stop CONTAINER
distrobox rm CONTAINER
```

> **WARNUNG:** Vor `distrobox rm` containerinterne Daten exportieren. Das gemeinsame Home bleibt normalerweise erhalten, benannte Volumes oder Daten im Container-Root jedoch nicht zwingend.

### Anwendungen und Binaries exportieren

Im Container:

```bash
distrobox-export --app DESKTOP_APP
distrobox-export --bin /usr/bin/PROGRAMM --export-path ~/.local/bin
distrobox-export --delete --app DESKTOP_APP
```

### Paketupdates im Container

```bash
# Fedora
sudo dnf upgrade --refresh

# Ubuntu/Debian
sudo apt update && sudo apt full-upgrade

# Arch
sudo pacman -Syu
```

> **INFO:** Diese Paketmanagerbefehle gelten nur innerhalb des passenden Containers, nicht als Bazzite-Hostanleitung.

Rootful Container nur bei zwingendem Bedarf:

```bash
distrobox create --root --name rootful-lab --image registry.fedoraproject.org/fedora:latest
```

## 4. Podman

### Container und Images

```bash
podman info
podman ps
podman ps --all
podman images
podman pull IMAGE
podman run --rm IMAGE BEFEHL
podman logs --tail 100 CONTAINER
podman logs --follow CONTAINER
podman exec -it CONTAINER sh
podman port CONTAINER
podman inspect CONTAINER
```

### Volumes und Netzwerke

```bash
podman volume ls
podman volume inspect VOLUME
podman network ls
podman network inspect NETZ
podman system df
```

### Compose

```bash
podman compose version
podman compose -f compose.yaml config
podman compose -f compose.yaml up -d
podman compose -f compose.yaml ps
podman compose -f compose.yaml down
```

> **INFO:** `podman compose` kann einen externen Compose-Provider verwenden. Für Autostart und langfristige Hostdienste Quadlet bevorzugen.

### Sichere und destruktive Bereinigung

```bash
podman system df
podman container prune --filter until=168h
podman image prune
```

> **WARNUNG:** `podman system prune --all --volumes` kann unbenutzte Images, Container, Netzwerke und Volumes mit Daten löschen. Nur nach `podman system df`, Volume-Backup und bewusster Einzelprüfung einsetzen.

## 5. Rootless Quadlet

```bash
mkdir -p ~/.config/containers/systemd
```

Beispiel `~/.config/containers/systemd/web.container`:

```ini
[Unit]
Description=Rootless Web-Test

[Container]
Image=docker.io/library/nginx:stable
PublishPort=127.0.0.1:8080:80
AutoUpdate=registry

[Service]
Restart=on-failure

[Install]
WantedBy=default.target
```

Aktivieren und prüfen:

```bash
systemctl --user daemon-reload
systemctl --user start web.service
systemctl --user status web.service
journalctl --user -u web.service -b
curl -I http://127.0.0.1:8080
```

Autostart ohne Anmeldung:

```bash
loginctl enable-linger "$USER"
systemctl --user daemon-reload
```

Rollback:

```bash
systemctl --user stop web.service
rm -i ~/.config/containers/systemd/web.container
systemctl --user daemon-reload
```

> **TIPP:** Container standardmäßig rootless, Ports nur an benötigte Interfaces binden, Secrets über Podman-Secrets statt in Quadlet-/Compose-Dateien verwalten und Images mit vertrauenswürdigem Registry-Pfad verwenden.

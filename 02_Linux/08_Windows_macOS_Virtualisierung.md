# 08 Windows und macOS in Docker (dockurr)

Verwaltung von virtuellen Maschinen (Windows & macOS), die innerhalb von Docker-Containern betrieben werden (z.B. basierend auf den Images `dockurr/windows` und `dockurr/macos`).
*Annahme:* Die Compose-Umgebungen liegen unter `~/windows` bzw. `~/macos-container`.

## 1. Container starten und verwalten

### 1.1 Starten (via Docker Compose)
```bash
# Windows
cd ~/windows && docker compose up -d

# macOS
cd ~/macos-container && docker compose up -d
```

### 1.2 Web-UI aufrufen
Die Container stellen standardmäßig eine Weboberfläche bereit (sofern in Compose konfiguriert):
```bash
# Windows (Standardport 8006)
xdg-open "http://127.0.0.1:8006/" 2>/dev/null || echo "URL: http://127.0.0.1:8006/"

# macOS (Standardport 8007)
xdg-open "http://127.0.0.1:8007/" 2>/dev/null || echo "URL: http://127.0.0.1:8007/"
```

### 1.3 Updates (Images aktualisieren)
```bash
cd ~/windows
docker compose pull
docker compose up -d
docker image prune -f
```

## 2. Einmaliger Start ohne Compose (Beispiel Windows)

Falls kein `docker-compose.yml` genutzt wird, kann der Container auch direkt über die CLI gestartet werden:

```bash
mkdir -p ~/windows/storage
docker run -d --name windows \
  -p 8006:8006 \
  --device=/dev/kvm \
  --device=/dev/net/tun \
  --cap-add NET_ADMIN \
  -v "$PWD/storage:/storage" \
  -e TZ=Europe/Berlin \
  --stop-timeout 120 \
  --restart unless-stopped \
  dockurr/windows:latest
```
*(Für macOS entsprechend Image, Pfade und Port 8007 anpassen)*

## 3. Backups und Wiederherstellung

Die virtuellen Festplatten (qcow2/raw) und Konfigurationen liegen im `storage`- bzw. `macos`-Ordner.

### 3.1 Backup erstellen (mittels rsync)
Der Container **muss** vorher gestoppt werden, um Datenkorruption zu vermeiden.
```bash
cd ~/windows
docker compose down

# Storage-Ordner inkrementell sichern
rsync -aHS --info=progress2 ./storage/ ~/container-backups/windows/

docker compose up -d
```

### 3.2 Backup wiederherstellen
```bash
cd ~/windows
docker compose down

# Alten Storage löschen und aus Backup wiederherstellen
rm -rf ./storage
rsync -aHS --info=progress2 ~/container-backups/windows/ ./storage/

docker compose up -d
```

## 4. Troubleshooting und Health-Checks

Die Virtualisierung benötigt zwingend KVM (`/dev/kvm`) und entsprechende Netzwerk-Capabilities.

```bash
# Prüfen, ob KVM (Hardware-Virtualisierung) auf dem Host verfügbar ist
[ -e /dev/kvm ] && echo "KVM ok" || echo "KVM fehlt"

# Prüfen, ob die benötigten Netzwerk-Capabilities (NET_ADMIN) gesetzt sind
docker inspect -f '{{json .HostConfig.CapAdd}}' windows
```

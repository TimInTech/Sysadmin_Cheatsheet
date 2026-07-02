# Docker und Container Troubleshooting (Linux)

Da Container in modernen Umgebungen allgegenwärtig sind, gibt es hier die wichtigsten Befehle zur Analyse und Reparatur von Docker-Umgebungen.

## 0. Version und Dienststatus

```bash
# Docker-Version und Engine-Info
docker version
docker info
docker context ls

# Dienststatus
systemctl status docker --no-pager
journalctl -u docker -b --no-pager | tail -n 160
```

## 1. Container und Logs prüfen

Wenn ein Container nicht startet oder sich seltsam verhält, ist der erste Blick immer ins Log gerichtet.

```bash
# Zeigt alle laufenden und gestoppten Container an
docker ps -a

# Logs eines bestimmten Containers live anzeigen (-f = follow)
docker logs -f container_name_oder_id

# Nur die letzten 100 Zeilen der Logs anzeigen
docker logs --tail 100 container_name
```

## 2. Container-Ressourcen und Prozesse

Manchmal frisst ein einzelner Container den gesamten RAM oder die CPU auf.

```bash
# Live-Ansicht des Ressourcenverbrauchs (CPU, RAM, Net I/O) aller Container
docker stats

# Zeigt die Prozesse an, die innerhalb eines bestimmten Containers laufen
docker top container_name
```

## 3. In einen laufenden Container einsteigen

Um Konfigurationen direkt im Container zu überprüfen oder Netzwerktester (`ping`, `curl`) auszuführen:

```bash
# Eine interaktive Bash-Shell im Container starten
docker exec -it container_name /bin/bash

# Falls keine Bash vorhanden ist (z. B. Alpine-Images), stattdessen 'sh' verwenden:
docker exec -it container_name sh
```

## 4. Speicherplatz-Bereinigung (Prune)

Siehe Abschnitt **10. Sicheres Cleanup** weiter unten.

## 5. Docker-Dienst / Daemon Probleme

Wenn `docker ps` einen Fehler wie `Cannot connect to the Docker daemon at unix:///var/run/docker.sock` wirft:

```bash
# Docker-Dienst neu starten
sudo systemctl restart docker

# Prüfen, ob der eigene Nutzer in der 'docker' Gruppe ist 
# (Sonst muss jedes Docker-Kommando mit 'sudo' ausgeführt werden)
groups
# Falls nicht vorhanden, Nutzer hinzufügen:
sudo usermod -aG docker $USER
# Danach ab- und wieder anmelden!
```

## 6. Compose-Projekte verwalten

Wenn mehrere Container zusammengehören (z. B. Web + DB + Cache) sind diese oft in einer `compose.yml` oder `docker-compose.yml` definiert.

```bash
# Compose-Dateien im Projektbaum finden
find . -maxdepth 4 -type f \( -name 'compose.yml' -o -name 'compose.yaml' \
  -o -name 'docker-compose.yml' -o -name 'docker-compose.yaml' \) -print

# Projektstatus und gerenderte Konfiguration
docker compose ps
docker compose config

# Logs aller Container des Projekts
docker compose logs --tail 160

# Container neu erstellen und starten
docker compose config > /tmp/compose.rendered.yml
docker compose up -d
docker compose ps
```

## 7. Docker-Netzwerke

Container kommunizieren über virtuelle Docker-Netzwerke. Diagnose bei Verbindungsproblemen:

```bash
# Alle Docker-Netzwerke anzeigen
docker network ls

# Detailinformationen zu einem Netzwerk (angeschlossene Container, IPAM, Treiber)
docker network inspect bridge

# Netzwerkkonfiguration eines bestimmten Containers anzeigen
docker inspect containername --format '{{json .NetworkSettings.Networks}}'

# Exportierte Ports eines Containers anzeigen
docker port containername

# DNS-Auflösung im Container testen
docker exec containername getent hosts example.com
```

## 8. Rootless Docker und Podman

Rootless-Docker läuft ohne root-Rechte und ist sicherer. Podman ist daemonlos und rootless-fähig.

```bash
# Prüfen ob Docker im Rootless-Modus läuft
docker info 2>/dev/null | grep -i rootless || true

# Rootless-Docker Dienst (user-scope)
systemctl --user status docker --no-pager 2>/dev/null || true

# Podman Version und Status
podman version 2>/dev/null || true
podman info 2>/dev/null || true
podman ps -a 2>/dev/null || true

# cgroup v2 (Voraussetzung für rootless)
stat -fc %T /sys/fs/cgroup
```

## 9. Volume-Backup und Restore

Docker-Volumes enthalten persistente Daten. Backup und Restore erfolgen über ein Hilfs-Container-Image (Alpine):

> **Hinweis:** Für konsistente Datenbanken vorher einen Dump erstellen oder den Dienst kurz stoppen.

```bash
# Alle Volumes anzeigen
docker volume ls

# Backup: Volume in tar.gz verpacken
docker run --rm -v volume_name:/data:ro -v "$PWD:/backup" alpine \
  sh -c "cd /data && tar czf /backup/volume-backup-$(date +%Y%m%d-%H%M%S).tar.gz ."

# Restore: tar.gz ins Volume entpacken
docker run --rm -v volume_name:/data -v "$PWD:/backup:ro" alpine \
  sh -c "cd /data && tar xzf /backup/backup-file.tar.gz"
```

## 10. Sicheres Cleanup

> **Warnung:** `docker system prune -a --volumes` löscht ungenutzte Images und Volumes unwiderruflich. Vorher Inventar, Backups und Volume-Inhalte prüfen.

```bash
# Speicherverbrauch detailliert anzeigen
docker system df
docker system df -v

# Ungenutzte Resourcen anzeigen (nur Liste, kein Löschen)
docker ps -a --filter status=exited
docker images --filter dangling=true
docker volume ls --filter dangling=true

# Cleanup OHNE Volumes (sicher)
docker system prune
docker system df

# Radikales Cleanup MIT Volumes (nur nach Prüfung)
docker system prune -a --volumes
```

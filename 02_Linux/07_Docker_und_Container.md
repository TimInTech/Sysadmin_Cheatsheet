# Docker und Container Troubleshooting (Linux)

Da Container in modernen Umgebungen allgegenwärtig sind, gibt es hier die wichtigsten Befehle zur Analyse und Reparatur von Docker-Umgebungen.

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

Docker kann mit der Zeit extrem viel Speicherplatz durch alte Images, ungenutzte Volumes und gestoppte Container belegen.

```bash
# Zeigt, wie viel Platz Docker aktuell belegt
docker system df

# Entfernt ALLE gestoppten Container, ungenutzten Netzwerke und baumelnden Images
docker system prune

# Radikal: Entfernt zusätzlich alle nicht verwendeten Volumes und ALLE ungenutzten Images 
# (ACHTUNG: Kann Daten aus gestoppten Projekten löschen!)
docker system prune -a --volumes
```

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

# Server-Dienste und Docker Wartung

Befehle für den schnellen Neustart, die Diagnose und die Verwaltung von wichtigen Diensten auf Servern oder Arbeitsstationen.

## 1. Systemd-Dienste (Linux)

Die Verwaltung von Hintergrunddiensten (Daemons) erfolgt unter Linux standardmäßig über `systemctl`.

### 1.1 Dienste steuern
```bash
# Status eines Dienstes prüfen (z.B. Nginx)
sudo systemctl status nginx

# Dienst neu starten (z.B. nach einer Konfigurationsänderung)
sudo systemctl restart nginx

# Dienst sanft neu laden (Konfiguration neu einlesen ohne Verbindungsabbruch)
sudo systemctl reload nginx

# Dienst stoppen / starten
sudo systemctl stop nginx
sudo systemctl start nginx
```

### 1.2 Autostart verwalten
```bash
# Dienst beim Systemstart aktivieren
sudo systemctl enable nginx

# Dienst beim Systemstart deaktivieren
sudo systemctl disable nginx
```

---

## 2. Docker Wartung (Linux)

Wenn Dienste in Docker-Containern laufen, sind folgende Befehle für die Wartung unerlässlich.

### 2.1 Container steuern
```bash
# Alle aktiven Container anzeigen
docker ps

# Alle (auch gestoppte) Container anzeigen
docker ps -a

# Einen Container neu starten
docker restart <container_id_oder_name>

# Container stoppen
docker stop <container_id_oder_name>
```

### 2.2 Docker-Logs und Diagnose
```bash
# Live-Logs eines Containers anzeigen (sehr wichtig für die Fehlersuche)
docker logs -f <container_id_oder_name>

# In einen laufenden Container einsteigen (Shell öffnen)
docker exec -it <container_id_oder_name> /bin/bash
# (Hinweis: Bei minimalen Images oft /bin/sh statt /bin/bash verwenden)
```

### 2.3 Docker aufräumen
```bash
# Nicht benötigte gestoppte Container, ungenutzte Netzwerke und ungenutzte Images löschen (schafft oft Gigabytes an Platz!)
docker system prune -a
```

---

## 3. Windows Dienste verwalten (PowerShell)

### 3.1 Dienste steuern
```powershell
# Status eines Dienstes abfragen
Get-Service -Name wuauserv

# Dienst neu starten
Restart-Service -Name wuauserv -Force

# Dienst stoppen / starten
Stop-Service -Name wuauserv -Force
Start-Service -Name wuauserv
```

### 3.2 Autostart konfigurieren
```powershell
# Dienst auf automatischen Start setzen
Set-Service -Name wuauserv -StartupType Automatic
```

### 3.3 Spezielle Windows-Dienste (IIS / SQL)
```cmd
:: Den IIS-Webserver komplett neu starten
iisreset

:: SQL-Server Dienst neu starten (Beispiel: Standardinstanz MSSQLSERVER)
net stop MSSQLSERVER
net start MSSQLSERVER
```

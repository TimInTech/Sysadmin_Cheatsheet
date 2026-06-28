# Speicher und Performance-Diagnose (Linux)

Wenn ein Linux-Server hängt, langsam reagiert oder Dienste abbrechen (häufig wegen fehlendem Speicherplatz oder Out-of-Memory-Killern), helfen folgende Konsolenbefehle bei der Diagnose.

## 1. Speicherplatz prüfen (No space left on device)

Oft stürzen Dienste wie MySQL oder Docker ab, wenn die Festplatte voll ist.

### 1.1 Gesamten Speicher und Mounts prüfen
```bash
# Übersicht des Dateisystems in menschenlesbarer Form
df -h

# Inklusive Anzeige des Dateisystem-Typs (ext4, btrfs, xfs)
df -hT
```

### 1.2 Speicherfresser (Große Dateien) finden
Wenn `df -h` eine volle Platte zeigt, hilft `du` bei der Suche nach den Verursachern:

```bash
# Größe aller Ordner im aktuellen Verzeichnis anzeigen
du -sh *

# Die 10 größten Verzeichnisse ab dem Wurzelverzeichnis (/) auflisten
sudo du -a / | sort -n -r | head -n 10
```

Alternativ `ncdu` (falls installiert) für eine interaktive, grafische Konsolenansicht nutzen:
```bash
sudo ncdu /
```

### 1.3 Inodes prüfen
Es kann passieren, dass die Festplatte noch freie Gigabytes hat, aber alle "Inodes" (Dateieinträge) aufgebraucht sind (oft durch Millionen winziger Dateien, z.B. Session-Files).
```bash
df -i
```

## 2. Arbeitsspeicher und Prozesse (System hängt)

### 2.1 RAM-Auslastung prüfen
```bash
# Übersicht des Arbeitsspeichers und Swap-Spaces
free -h
```
*(Hinweis: Unter Linux ist ein hoher Wert bei "buff/cache" normal und kein Grund zur Sorge. Der Wert bei "available" ist entscheidend).*

### 2.2 Prozesse analysieren
```bash
# Die rudimentäre Prozessliste (Live)
top

# Besser (falls installiert): htop für farbige und interaktive Darstellung
htop
```

**Prozesse im Terminal sortieren (ohne htop):**
```bash
# Top 10 CPU-Fresser anzeigen
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 11

# Top 10 RAM-Fresser anzeigen
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 11
```

### 2.3 Prozesse beenden (kill)
Wenn ein Prozess hängt und nicht mehr auf reguläre Befehle reagiert:
```bash
# Reguläres Beenden anfordern (SIGTERM)
kill PID_NUMMER

# Prozess erzwingen abschießen (SIGKILL, letztes Mittel)
kill -9 PID_NUMMER

# Alle Prozesse mit einem bestimmten Namen killen (z.B. alle PHP-Worker)
killall -9 php-fpm
```

## 3. OOM (Out Of Memory) Log überprüfen
Wenn Dienste "einfach so" verschwinden, hat der Linux-Kernel sie womöglich aus Speichermangel getötet.
```bash
sudo dmesg | grep -i "killed process"
```

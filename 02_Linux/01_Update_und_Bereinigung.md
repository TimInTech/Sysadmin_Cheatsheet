# 01 Update und Bereinigung (Linux)

Fokus auf debianbasierte Systeme (Ubuntu, Kubuntu, Linux Mint).

## 1. Vollständige Update-Ketten

### 1.1 APT (Advanced Packaging Tool)
Der Standard-Weg für Updates.
```bash
# Paketlisten aktualisieren
sudo apt update

# Sicheres Upgrade (behält Abhängigkeiten)
sudo apt upgrade -y

# Vollständiges Upgrade (darf Pakete entfernen/ersetzen, falls nötig)
sudo apt full-upgrade -y

# Als One-Liner (Standard für Server-Wartung):
sudo apt update && sudo apt full-upgrade -y
```

### 1.2 Snap & Flatpak Update-Routinen
Viele moderne Distributionen setzen zusätzlich auf Snap und Flatpak.
```bash
# Alle Snaps aktualisieren
sudo snap refresh

# Alle Flatpaks aktualisieren
flatpak update -y
```

## 2. Systembereinigung

Ein sauberes System ist essenziell für die Stabilität und spart Gigabytes an Speicher.

### 2.1 APT-Cache und Waisen bereinigen
```bash
# Entfernt Pakete und deren Konfigurationsdateien, die nicht mehr benötigt werden
sudo apt autoremove --purge -y

# Leert den heruntergeladenen APT-Cache vollständig
sudo apt clean

# Entfernt nur veraltete (nicht mehr ladbare) Pakete aus dem Cache
sudo apt autoclean
```

### 2.2 Flatpak & Snap aufräumen
```bash
# Nicht mehr benötigte Flatpak-Runtimes entfernen
flatpak uninstall --unused -y

# Bei Snap gibt es kein direktes "clean", aber man kann alte Revisionen per Skript löschen:
# ACHTUNG: Beendet alle Snaps kurzzeitig!
sudo snap set system refresh.retain=2
```

### 2.3 Journalctl (System Logs) bereinigen
Systemd-Logs (Journals) können über die Zeit massiv anwachsen.
```bash
# Logs löschen, die älter als 7 Tage sind
sudo journalctl --vacuum-time=7d

# Logs auf eine feste Größe (z.B. 100MB) reduzieren
sudo journalctl --vacuum-size=100M
```

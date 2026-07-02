# Benutzerverwaltung und Berechtigungen (Linux)

Standardbefehle zur Verwaltung von Benutzern, Gruppen und Admin-Rechten (`sudo`) unter Debian/Ubuntu basierten Systemen.

## 0. Benutzer und Gruppen anzeigen

```bash
# Alle lokalen Benutzer mit UID und Shell anzeigen
getent passwd | cut -d: -f1,3,7 | column -t -s:

# Admin-Gruppen prüfen
getent group sudo wheel admin 2>/dev/null

# Eigene sudo-Rechte prüfen
sudo -l
```

## 1. Benutzerverwaltung

### Neuen Benutzer anlegen
Die empfohlene Methode (legt auch das Home-Verzeichnis `/home/username` an und fragt interaktiv nach Passwort und Details):
```bash
sudo adduser neuer_benutzer
```
*(Hinweis: `useradd` ist der Low-Level-Befehl und erfordert oft manuelle Schalter für Home-Dir und Shell, daher auf Debian/Ubuntu immer `adduser` bevorzugen).*

### Passwort ändern
```bash
sudo passwd benutzername
```

### Benutzer löschen
Löscht den Nutzer und sein Home-Verzeichnis (`--remove-home`):
```bash
sudo deluser --remove-home benutzername
```

## 2. Admin-Rechte (Sudo) vergeben

Damit ein Benutzer Befehle als Administrator ausführen darf, muss er in der Gruppe `sudo` (unter Debian/Ubuntu) bzw. `wheel` (unter RHEL/CentOS) sein.

```bash
# Nutzer der sudo-Gruppe hinzufügen (Debian/Ubuntu)
sudo usermod -aG sudo benutzername
```

Um zu prüfen, welchen Gruppen ein Nutzer angehört:
```bash
groups benutzername
```

## 3. Sudoers-Datei bearbeiten (visudo)
Wenn spezifischere Berechtigungen (z. B. Ausführen eines Befehls *ohne* Passwortabfrage) konfiguriert werden sollen, **immer** `visudo` nutzen. Es prüft die Syntax vor dem Speichern!
```bash
# Sudoers-Datei bearbeiten
sudo visudo

# Syntax der aktuellen Sudoers-Datei prüfen
sudo visudo -cf /etc/sudoers

# Auch alle Include-Dateien prüfen
find /etc/sudoers.d -maxdepth 1 -type f -exec sudo visudo -cf {} \;
```
*Beispiel-Eintrag am Ende der Datei (Nutzer darf `systemctl restart nginx` ohne Passwort ausführen):*
`benutzername ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx`

## 4. Rechte und Besitz (chmod & chown)

### Dateibesitzer ändern (chown)
Den Besitzer (und die Gruppe) einer Datei oder eines Ordners ändern:
```bash
# Benutzer und Gruppe auf 'www-data' (Webserver) ändern, rekursiv (-R)
sudo chown -R www-data:www-data /var/www/html
```

### Dateiberechtigungen ändern (chmod)
Die gängigsten oktalen Berechtigungen:
- `777` = Jeder darf alles (Gefährlich, nur für temporäres Debugging)
- `755` = Besitzer darf alles, andere dürfen lesen und ausführen (Standard für Ordner)
- `644` = Besitzer darf lesen/schreiben, andere nur lesen (Standard für Dateien)

```bash
# Rekursiv Rechte für Dateien und Ordner anpassen (häufig benötigt bei Webservern):
# Setze alle Ordner auf 755
find /var/www/html -type d -exec chmod 755 {} \;

# Setze alle Dateien auf 644
find /var/www/html -type f -exec chmod 644 {} \;
```

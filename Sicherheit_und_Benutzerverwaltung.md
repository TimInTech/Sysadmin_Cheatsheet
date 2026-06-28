# Sicherheit und Benutzerverwaltung

Befehle zur Absicherung des Systems, Prüfung von Berechtigungen und Abwehr von Zugriffen.

## 1. Linux Sicherheit & Benutzer

### 1.1 Benutzerverwaltung
```bash
# Neuen Benutzer anlegen
sudo adduser <benutzername>

# Benutzer zu den Sudoern (Administratoren) hinzufügen
sudo usermod -aG sudo <benutzername>

# Passwort eines Benutzers ändern
sudo passwd <benutzername>

# Benutzer löschen (inklusive Home-Verzeichnis)
sudo deluser --remove-home <benutzername>
```

### 1.2 Dateirechte und Besitz (chmod & chown)
Falsche Berechtigungen können Webserver zum Absturz bringen oder Sicherheitslücken öffnen.
```bash
# Besitzer einer Datei / eines Verzeichnisses ändern
sudo chown -R www-data:www-data /var/www/html/

# Standard-Rechte für Web-Verzeichnisse setzen (Ordner 755, Dateien 644)
sudo find /var/www/html/ -type d -exec chmod 755 {} \;
sudo find /var/www/html/ -type f -exec chmod 644 {} \;
```

### 1.3 Offene Ports und Verbindungen prüfen
Welche Dienste lauschen auf welchen Ports?
```bash
# Alle offenen Ports und zugehörigen Prozesse anzeigen
sudo ss -tulpen

# Alternativ (falls net-tools installiert sind)
sudo netstat -tulpen
```

### 1.4 Hacking-Abwehr (Fail2Ban)
Fail2Ban blockiert IPs nach zu vielen fehlgeschlagenen Login-Versuchen.
```bash
# Fail2Ban Status anzeigen
sudo fail2ban-client status

# Status für einen spezifischen Dienst (z.B. SSH) anzeigen (inklusive blockierter IPs)
sudo fail2ban-client status sshd

# Eine versehentlich blockierte IP wieder freigeben
sudo fail2ban-client set sshd unbanip 192.168.1.50
```

---

## 2. Windows Sicherheit & Benutzer

### 2.1 Lokale Benutzerverwaltung (CMD / PowerShell)
```cmd
:: Neuen lokalen Benutzer anlegen
net user NeuerBenutzer "GeheimPasswort123!" /add

:: Benutzer zur Gruppe der Administratoren hinzufügen
net localgroup Administratoren NeuerBenutzer /add

:: Passwort eines Benutzers ändern
net user NeuerBenutzer "NeuesPasswort456!"
```

### 2.2 Dateirechte reparieren (icacls)
Manchmal zerschießen Updates oder Software die NTFS-Berechtigungen.
```cmd
:: Berechtigungen für einen Ordner anzeigen
icacls C:\WichtigerOrdner

:: Dem Administrator Vollzugriff auf einen Ordner geben
icacls C:\WichtigerOrdner /grant Administratoren:(OI)(CI)F /T

:: Berechtigungen auf Vererbung vom übergeordneten Ordner zurücksetzen
icacls C:\WichtigerOrdner /reset /T /C /Q
```

### 2.3 Offene Ports prüfen
```cmd
:: Alle aktiven Verbindungen und lauschenden Ports anzeigen (mit Prozess-ID)
netstat -ano

:: Herausfinden, welcher Prozess hinter einer PID steckt (z.B. PID 1234)
tasklist | findstr 1234
```

# SSH-Einrichtung für Windows und Linux

Die sichere Remote-Verwaltung von Servern und Clients erfolgt nahezu ausschließlich über SSH (Secure Shell). Hier findest du alle nötigen Befehle, um SSH auf Linux und Windows (via PowerShell) blitzschnell einzurichten und abzusichern.

## 1. SSH unter Linux einrichten

### 1.1 SSH-Server (OpenSSH) installieren
```bash
# Paketlisten aktualisieren und OpenSSH Server installieren
sudo apt update && sudo apt install -y openssh-server

# Status prüfen (sollte "active (running)" sein)
sudo systemctl status ssh
```

### 1.2 SSH-Dienst verwalten
```bash
# Dienst neu starten
sudo systemctl restart ssh

# Dienst beim Systemstart automatisch aktivieren
sudo systemctl enable ssh
```

### 1.3 Firewall (UFW) konfigurieren
```bash
# SSH-Verbindungen in der Firewall erlauben
sudo ufw allow ssh
# Alternativ mit spezifischem Port (Standard 22):
sudo ufw allow 22/tcp
sudo ufw reload
```

### 1.4 SSH-Schlüssel generieren (Empfohlen für Sicherheit)
Anstatt Passwörter zu nutzen, sollten kryptografische Schlüsselpaare (Public/Private Key) verwendet werden.
```bash
# Einen sicheren ED25519-Schlüssel generieren
ssh-keygen -t ed25519 -C "admin@meine-domain.com"

# Den öffentlichen Schlüssel auf einen Zielserver kopieren
ssh-copy-id benutzer@zielserver-ip
```

---

## 2. SSH unter Windows einrichten (PowerShell)

Seit Windows 10 (Version 1809) und in Windows 11 sind OpenSSH-Client und -Server integriert, müssen aber oft noch aktiviert werden. **Alle Befehle in einer administrativen PowerShell ausführen.**

### 2.1 OpenSSH-Client und -Server installieren
```powershell
# Prüfen, ob SSH bereits installiert ist
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

# OpenSSH-Client installieren (falls noch nicht vorhanden)
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# OpenSSH-Server installieren (Für Remote-Zugriff AUF diesen Windows-PC)
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

### 2.2 SSH-Dienst starten und auf Automatisch setzen
```powershell
# Den Dienst starten
Start-Service sshd

# Dienst-Startart auf Automatisch ändern
Set-Service -Name sshd -StartupType 'Automatic'
```

### 2.3 Firewall-Regel überprüfen / setzen
Normalerweise legt Windows die Firewall-Regel automatisch an. Zur Sicherheit kann diese geprüft oder manuell erstellt werden:
```powershell
# Prüfen ob Regel existiert
Get-NetFirewallRule -Name *ssh*

# Wenn sie fehlt, Regel manuell hinzufügen:
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

### 2.4 SSH-Schlüssel unter Windows generieren
```powershell
# Genauso wie unter Linux!
ssh-keygen -t ed25519 -C "admin@windows-client"

# Schlüssel ausgeben, um ihn manuell in die authorized_keys des Linux-Servers zu kopieren
cat $env:USERPROFILE\.ssh\id_ed25519.pub
```

---

> [!TIP]
> **Sicherheits-Best-Practice:**
> Sobald du dich erfolgreich per SSH-Key einloggen kannst, deaktiviere die Passwort-Authentifizierung auf dem Server! Unter Linux geht das in der `/etc/ssh/sshd_config` durch Setzen von `PasswordAuthentication no`. Vergiss danach `sudo systemctl restart ssh` nicht!

# OpenSSH-Server unter Windows 10/11: Zugriff von Ubuntu/Kubuntu

Ziel: Windows als **SSH-Server** einrichten und von einem Linux-Rechner aus im **lokalen Netzwerk** sicher per SSH, SCP oder SFTP darauf zugreifen. Auf Windows ist eine **PowerShell als Administrator** erforderlich, soweit angegeben.

> **Sicherheit:** Keine Portweiterleitung (TCP 22) auf der FRITZ!Box einrichten. Zugriff zunächst nur im privaten LAN. Vor Änderungen an Firewall und SSH-Konfiguration vorhandenen Status prüfen. Windows-Hello-PIN ist kein SSH-Kontokennwort.

## 1. Windows: Status prüfen (PowerShell, Administrator)

```powershell
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
Get-Service -Name sshd -ErrorAction SilentlyContinue
Get-NetConnectionProfile
Get-NetFirewallRule -Name OpenSSH-Server-In-TCP -ErrorAction SilentlyContinue | Format-List Name,Enabled,Profile,Direction,Action
Get-NetTCPConnection -LocalPort 22 -State Listen -ErrorAction SilentlyContinue
```

- `OpenSSH.Server... State : Installed`: Server bereits vorhanden.
- `sshd : Running`: Dienst läuft.
- `Private`: privates Netzwerkprofil (Netzwerktyp vor Änderungen verifizieren).
- Fehlender Dienst oder `NotPresent`: Installation in Schritt 2.

## 2. Windows: Server installieren und starten (PowerShell, Administrator)

```powershell
$capability = Get-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0'
if ($capability.State -ne 'Installed') {
    Add-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0' -ErrorAction Stop
}
Set-Service -Name sshd -StartupType Automatic
Start-Service -Name sshd
Get-Service -Name sshd
```

Installation über Windows-Features kann Windows Update oder eine passende optionale Feature-Quelle voraussetzen. Fehler erst diagnostizieren, nicht blind andere Pakete installieren.

## 3. Windows-Firewall im LAN prüfen

Windows erstellt bei der OpenSSH-Installation üblicherweise die Regel `OpenSSH-Server-In-TCP`. Erst prüfen, **keine zweite pauschale Regel hinzufügen**, wenn Port 22 bereits zugelassen ist.

```powershell
Get-NetFirewallRule -Name OpenSSH-Server-In-TCP -ErrorAction SilentlyContinue | Get-NetFirewallPortFilter
Get-NetFirewallRule -Name OpenSSH-Server-In-TCP -ErrorAction SilentlyContinue | Get-NetFirewallAddressFilter
Get-NetFirewallRule -Name OpenSSH-Server-In-TCP -ErrorAction SilentlyContinue | Format-List Name,Enabled,Profile,Action
Get-NetConnectionProfile
```

Wenn die Standardregel fehlt und das Zielnetz **Private** ist, ausschließlich eine eingeschränkte neue Regel anlegen:

```powershell
if (-not (Get-NetFirewallRule -Name 'OpenSSH-LAN-Private-TCP22' -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name 'OpenSSH-LAN-Private-TCP22' -DisplayName 'OpenSSH only private LAN' -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow -Profile Private -RemoteAddress LocalSubnet
}
```

**Hinweis:** Eine bereits vorhandene aktive Standardregel kann einen größeren Adressbereich erlauben. Die neue eingeschränkte Regel schränkt sie **nicht** nachträglich ein. Bei erhöhten Sicherheitsanforderungen bestehende Regeln gezielt prüfen und separat härten. Firewall niemals unkontrolliert zurücksetzen.

## 4. Windows: Benutzer und IPv4-Adresse feststellen

```powershell
whoami
hostname
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '169.254*' -and $_.IPAddress -ne '127.0.0.1' } | Format-Table InterfaceAlias,IPAddress
```

Bei `whoami` erscheint häufig `COMPUTERNAME\Benutzername`. Für lokale Konten normalerweise den Teil **nach** dem Backslash als SSH-Benutzernamen verwenden. Bei Microsoft-/Domänenkonten kann die Anmeldeschreibweise abweichen. Für SSH wird das **Kontokennwort**, nicht die Windows-Hello-PIN verwendet.

## 5. Ubuntu/Kubuntu: Client prüfen und verbinden

```bash
ssh -V
```

Falls der Client fehlt:

```bash
sudo apt update
sudo apt install openssh-client
```

Die folgenden Eingabeaufforderungen fragen die **tatsächlichen** Windows-Werte ab, ohne Beispiel-IP-Adressen vorzutäuschen:

```bash
read -r -p "Windows-IPv4-Adresse: " WIN_IP
read -r -p "Windows-SSH-Benutzername: " WIN_USER
ssh -o StrictHostKeyChecking=ask "${WIN_USER}@${WIN_IP}"
```

Den angezeigten Host-Key-Fingerabdruck **vor Bestätigung** auf Windows prüfen:

```powershell
ssh-keygen -lf "$env:ProgramData\ssh\ssh_host_ed25519_key.pub"
```

Nur bei Übereinstimmung `yes` eingeben. Bei einer bestehenden geänderten Host-Key-Warnung nicht blind `known_hosts` löschen.

## 6. Verbindung und Port diagnostizieren

**Windows (PowerShell, Administrator):**

```powershell
Get-Service sshd
Get-NetTCPConnection -LocalPort 22 -State Listen -ErrorAction SilentlyContinue
Get-WinEvent -ListLog 'OpenSSH/Operational' -ErrorAction SilentlyContinue
Get-WinEvent -LogName 'OpenSSH/Operational' -MaxEvents 20 -ErrorAction SilentlyContinue | Format-List TimeCreated,Id,LevelDisplayName,Message
```

**Ubuntu:**

```bash
read -r -p "Windows-IPv4-Adresse: " WIN_IP
nc -vz -w 3 "$WIN_IP" 22
```

Wenn `nc` fehlt: `sudo apt install netcat-openbsd`. Bei Verbindungsfehlern mit SSH detailliert testen:

```bash
read -r -p "Windows-IPv4-Adresse: " WIN_IP
read -r -p "Windows-SSH-Benutzername: " WIN_USER
ssh -vvv "${WIN_USER}@${WIN_IP}"
```

- `Connection refused`: Dienst lauscht nicht oder Port wird aktiv abgelehnt.
- Timeout: IP, Netzwerksegment, Windows-Firewall, Router-/Gastnetz-Isolation prüfen.
- `Permission denied`: Benutzername, Kontokennwort und SSH-Authentifizierung prüfen.
- `REMOTE HOST IDENTIFICATION HAS CHANGED`: Host-Key auf Windows separat verifizieren; erst dann bekannten Schlüssel gezielt aktualisieren.

## 7. Dateien übertragen (Ubuntu)

SCP-Beispiel mit interaktiv abgefragten Angaben und vorhandener Quelldatei:

```bash
read -r -p "Windows-IPv4-Adresse: " WIN_IP
read -r -p "Windows-SSH-Benutzername: " WIN_USER
read -r -p "Pfad einer lokalen Datei (Ubuntu): " LOCAL_FILE
scp -- "$LOCAL_FILE" "${WIN_USER}@${WIN_IP}:"
```

Ziel ist das Startverzeichnis des Windows-SSH-Benutzers. Für interaktive Übertragungen:

```bash
read -r -p "Windows-IPv4-Adresse: " WIN_IP
read -r -p "Windows-SSH-Benutzername: " WIN_USER
sftp "${WIN_USER}@${WIN_IP}"
```

## 8. Optional: Schlüsselanmeldung und Härtung

- Auf Ubuntu bei Bedarf mit `ssh-keygen -t ed25519` ein separates Schlüsselpaar erzeugen; bestehenden Key **nicht überschreiben**.
- Den **öffentlichen** Schlüssel unter Windows für Standardbenutzer in `%USERPROFILE%\.ssh\authorized_keys` hinterlegen. Für Konten in der Windows-Administratoren-Gruppe verwendet die Standardkonfiguration häufig `%ProgramData%\ssh\administrators_authorized_keys`, mit besonderen ACL-Anforderungen.
- Zuerst einen zweiten Login mit Schlüssel testen. Passwortanmeldung **erst danach** deaktivieren, wenn gewünscht; sonst droht Aussperrung.
- Windows-OpenSSH-Konfiguration: `%ProgramData%\ssh\sshd_config`. Vor Änderungen sichern; mit `sshd -t` auf Syntax prüfen.
- Keine privaten Schlüssel, Kennwörter oder persönlichen IP-Adressen ins Repository committen.

## 9. Rückbau (Windows, PowerShell als Administrator)

Nur wenn der SSH-Server nicht mehr gewünscht ist:

```powershell
Stop-Service sshd -ErrorAction SilentlyContinue
Set-Service sshd -StartupType Disabled
```

Die selbst angelegte Firewallregel gegebenenfalls nach Prüfung entfernen:

```powershell
Get-NetFirewallRule -Name 'OpenSSH-LAN-Private-TCP22' -ErrorAction SilentlyContinue
```

Die Ausgabe prüfen; anschließend nur bei Bedarf `Remove-NetFirewallRule -Name 'OpenSSH-LAN-Private-TCP22'` ausführen.

## Quellen

- [Microsoft Learn: OpenSSH für Windows installieren](https://learn.microsoft.com/de-de/windows-server/administration/openssh/openssh_install_firstuse)
- [Microsoft Learn: OpenSSH-Schlüsselverwaltung](https://learn.microsoft.com/de-de/windows-server/administration/openssh/openssh_keymanagement)
- [Linux: SSH und Remote-Zugriff](../02_Linux/04_SSH_und_Remote_Zugriff.md)

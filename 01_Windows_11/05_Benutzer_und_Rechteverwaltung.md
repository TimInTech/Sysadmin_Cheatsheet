# Benutzer- und Rechteverwaltung (Windows 11)

In dieser Sammlung finden sich die wichtigsten PowerShell- und CMD-Befehle, um lokale Benutzerkonten und Gruppen zu verwalten, Passwörter zurückzusetzen und Berechtigungsprobleme zu lösen.

## 1. Lokale Benutzerverwaltung

### Neuen Benutzer anlegen
Einen neuen lokalen Benutzer mit Passwort erstellen (CMD/PowerShell als Administrator):
```powershell
$Password = Read-Host "Passwort fuer den neuen Benutzer" -AsSecureString
New-LocalUser -Name "NeuerBenutzername" -Password $Password -Description "Beschreibung des Kontos"
```

Alternativ fuer ein Konto ohne Passwort:
```powershell
New-LocalUser -Name "NeuerBenutzername" -Description "Beschreibung des Kontos" -NoPassword
```
Keine Passwoerter direkt in Befehlen dokumentieren oder in Shell-Historien schreiben.

### Benutzer in die lokale Administratorgruppe aufnehmen
```powershell
net localgroup Administratoren NeuerBenutzername /add
```
Oder via PowerShell:
```powershell
Add-LocalGroupMember -Group "Administratoren" -Member "NeuerBenutzername"
```

### Passwort eines Benutzers zurücksetzen
```powershell
$Password = Read-Host "Neues Passwort" -AsSecureString
Set-LocalUser -Name "Benutzername" -Password $Password
```

### Konto aktivieren oder deaktivieren
Beispiel: Das versteckte lokale Administrator-Konto aktivieren:
```powershell
net user Administrator /active:yes
```
Deaktivieren:
```powershell
net user Administrator /active:no
```

## 2. Active Directory & Domänen (Grundlagen)

### Prüfen, an welchem Domain Controller der PC angemeldet ist
```powershell
nltest /dsgetdc:DeinDomainName
```

### Computername ändern (PowerShell)
```powershell
Rename-Computer -NewName "NeuerPCName" -Restart
```

### Computer in eine Domäne aufnehmen
```powershell
Add-Computer -DomainName "deinedomaene.local" -Credential "deinedomaene\AdminUser" -Restart
```

## 3. Berechtigungen (NTFS)

Wenn der Zugriff auf Ordner verweigert wird, können Rechte per Kommandozeile neu gesetzt werden.

> **Warnung:** Rekursive `takeown`- und `icacls`-Befehle verändern Besitz und Berechtigungen ganzer Ordnerbäume. Vorher Pfad, Backup/Snapshot und benötigte Vererbungsregeln prüfen.

Backup und Verifikation vor rekursiven Aenderungen:

```powershell
icacls "C:\Pfad\Zum" /save "$env:TEMP\acl-backup.txt" /T
icacls "C:\Pfad\Zum\Ordner"
```

### Besitz eines Ordners übernehmen (takeown)
Übernimmt den Besitz eines Ordners und aller Unterordner für den aktuell angemeldeten Admin:
```powershell
takeown /f "C:\Pfad\Zum\Ordner" /r /d j
```

### Vollzugriff gewähren (icacls)
Nachdem der Besitz übernommen wurde, dem lokalen Administrator Vollzugriff gewähren:
```powershell
icacls "C:\Pfad\Zum\Ordner" /grant Administratoren:(OI)(CI)F /T
```
*(OI) = Object Inherit, (CI) = Container Inherit, F = Full Control, /T = Rekursiv.*

Verifikation und Rollback:

```powershell
icacls "C:\Pfad\Zum\Ordner"
icacls "C:\Pfad\Zum" /restore "$env:TEMP\acl-backup.txt"
```

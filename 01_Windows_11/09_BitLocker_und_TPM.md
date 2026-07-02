# 09 BitLocker und TPM (Windows 11)

BitLocker schuetzt Windows-Systemlaufwerke und Datenlaufwerke, kann bei Firmware-, TPM- oder Boot-Aenderungen aber auch legitime Admins aussperren. Erst pruefen, dann entsperren oder Schutz kurzzeitig pausieren.

Quellen:

- Microsoft Learn: <https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/manage-bde>
- Microsoft Learn BitLocker Operations Guide: <https://learn.microsoft.com/en-us/windows/security/operating-system-security/data-protection/bitlocker/operations-guide>

## 1. Status und Schutzmechanismen pruefen

```powershell
# BitLocker-Status über PowerShell-Cmdlet und CLI
Get-BitLockerVolume
manage-bde -status

# Schutzmechanismen fuer C: anzeigen
manage-bde -protectors -get C:

# TPM-Status in PowerShell pruefen
Get-Tpm
```

Pruefpunkte:

- Ist der Schutz fuer das richtige Laufwerk aktiv?
- Gibt es einen Recovery-Key oder eine Recovery-ID?
- Ist TPM aktiv, bereit und im erwarteten Zustand?

## 2. Recovery-Key sichern und verifizieren

> **Warnung:** Ohne verifizierten Recovery-Key kann ein TPM-, Firmware- oder Boot-Fehler zum Datenverlust fuehren. Recovery-Keys niemals in Tickets, Chatverlaeufen oder Klartext-Notizen ablegen.

```powershell
# Recovery-Protectoren anzeigen, ohne neue Secrets zu erzeugen
manage-bde -protectors -get C:

# Recovery-Key nach Organisationsstandard sichern, z.B. AD/Azure AD/MDM oder Offline-Tresor
# Danach mit einem zweiten Admin oder separatem Konto verifizieren.
```

Verifikation:

```powershell
# Recovery-ID erneut anzeigen und mit dem dokumentierten Eintrag abgleichen
manage-bde -protectors -get C:
```

Rollback:

- Wenn kein gueltiger Recovery-Key nachweisbar ist, keine Firmware-, TPM-, BIOS/UEFI- oder Bootloader-Aenderungen durchfuehren.
- Wartung verschieben, bis der Key sicher abgelegt und wieder auffindbar ist.

## 3. Schutz fuer Wartung kurzzeitig pausieren

Das ist sinnvoll vor BIOS/UEFI-Updates, Bootloader-Reparaturen oder TPM-relevanten Aenderungen.

> **Warnung:** Suspend reduziert den Schutz des Laufwerks bis zum naechsten Resume oder Neustartfenster. Nur fuer ein enges Wartungsfenster verwenden und danach verifizieren.

```powershell
# Schutz bis zum naechsten Neustart pausieren
manage-bde -protectors -disable C: -RebootCount 1

# Status kontrollieren
manage-bde -status C:
```

Verifikation nach der Wartung:

```powershell
# Schutz wieder aktivieren
manage-bde -protectors -enable C:

# Schutzstatus pruefen
manage-bde -status C:
```

Rollback:

```powershell
# Falls die Wartung abgebrochen wurde, Schutz sofort wieder einschalten
manage-bde -protectors -enable C:
```

## 4. Datenlaufwerk entsperren

```powershell
# Verschluesseltes Datenlaufwerk mit Recovery-Key-Datei entsperren
manage-bde -unlock D: -RecoveryKey "E:\RecoveryKey.bek"

# Alternativ mit Recovery-Passwort interaktiv in einer sicheren Admin-Sitzung arbeiten
manage-bde -unlock D: -RecoveryPassword
```

Verifikation:

```powershell
manage-bde -status D:
```

## 5. BitLocker deaktivieren nur mit Auftrag

> **Warnung:** `manage-bde -off` entschluesselt das Laufwerk und entfernt den Schutz. Vorher Datenbackup, Recovery-Key-Nachweis, Wartungsfenster und Geraetezuordnung pruefen.

```powershell
# BitLocker fuer ein Datenlaufwerk deaktivieren
manage-bde -off D:

# Fortschritt beobachten
manage-bde -status D:
```

Rollback:

```powershell
# Schutz nach Abschluss wieder aktivieren, wenn die Deaktivierung nur temporaer war
manage-bde -on D: -RecoveryPassword
```

## 6. Microsoft Defender Status

```powershell
# Defender-Status und letzter Scan
Get-MpComputerStatus

# Aktuelle Defender-Konfiguration
Get-MpPreference
```

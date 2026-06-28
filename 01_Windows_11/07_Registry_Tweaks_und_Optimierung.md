# 07 Registry Tweaks und Optimierung (Windows 11)

⚠ **WICHTIGER HINWEIS:** Änderungen an der Windows-Registry wirken direkt auf essenzielle Systemfunktionen.
Vor jeder Änderung:
- **Backup der Registry erstellen** (`reg export HKLM\... backup.reg`)
- **Wiederherstellungspunkt setzen** (siehe `03_Systemreparatur_und_Wartung.md`)
- Alle Befehle erfordern **Administratorrechte** (CMD / PowerShell).

---

## 1. Upgrade-Falle umgehen (c't Registry Trick)

Wenn Windows 11 Updates oder Upgrades (z.B. auf 24H2) aufgrund von angeblich "inkompatibler" Hardware (fehlendes TPM 2.0, zu alte CPU, weniger als 4 GB RAM) verweigert, helfen diese beiden Registry-Schlüssel. Sie zwingen das Setup-Programm, die Hardwareprüfungen zu ignorieren.

```powershell
# 1. CPU- und TPM-Überprüfung beim Upgrade überspringen
Reg.exe Add "HKLM\SYSTEM\Setup\MoSetup" /v AllowUpgradesWithUnsupportedTPMOrCPU /t REG_DWORD /d 1 /f

# 2. Erweiterter Hardware-Check-Bypass (Secure Boot, TPM, RAM, CPU)
# (Hinweis: Dies fügt spezielle Bypass-Werte in AppCompatFlags ein)
Reg.exe Add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\HwReqChk" /v HwReqChkVars /t REG_MULTI_SZ /d "SQ_SecureBootCapable=TRUE\0SQ_SecureBootEnabled=TRUE\0SQ_TpmVersion=2\0SQ_RamMB=8192\0" /f
```
*(Hinweis: Nach Setzen dieser Schlüssel muss das Upgrade über eine heruntergeladene ISO per `setup.exe` manuell angestoßen werden. Siehe `01_Update_und_Upgrade.md`)*

---

## 2. Windows Update & Neustart-Steuerung

Windows-Updates und damit verbundene automatische Neustarts können für Administratoren störend sein. Diese Tweaks geben die Kontrolle zurück.

### 2.1 Automatische Updates komplett steuern

```powershell
# Automatische Updates komplett deaktivieren (nur noch manuelle Suche)
Reg.exe Add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f

# Alternativ: Nur Benachrichtigen vor Download und Installation (Option 2)
Reg.exe Add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 2 /f

# Alternativ: Auto-Download, aber manuelle Installation (Option 3)
Reg.exe Add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 3 /f
```

### 2.2 Automatischen Neustart verhindern

Verhindert, dass Windows nach einem Update automatisch neu startet, wenn ein Benutzer angemeldet ist.

```powershell
Reg.exe Add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoRebootWithLoggedOnUsers /t REG_DWORD /d 1 /f
```

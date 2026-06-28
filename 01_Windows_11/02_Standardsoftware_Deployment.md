# 02 Standardsoftware Deployment (Windows 11)

Windows 11 bringt den Paketmanager `winget` mit, der die Softwareverteilung revolutioniert.

## 1. Winget initialisieren (Erster Start)

Oft ist `winget` bei einer frischen Windows-Installation noch nicht sofort ausführbar, nicht aktuell oder verlangt beim ersten Start eine interaktive Bestätigung (Zustimmung zu den Lizenzbedingungen). Folgende Befehle lösen dieses Problem:

### 1.1 Nutzungsbedingungen automatisch akzeptieren
Wenn `winget` zwar vorhanden ist, aber beim ersten Start in Skripten hängen bleibt, nutze diesen Befehl, um die Bedingungen (Source Agreements) global zu akzeptieren:
```powershell
# Führt eine leere Suche aus und akzeptiert dabei alle Bedingungen für zukünftige Aufrufe
winget search "winget" --accept-source-agreements
```

### 1.2 Winget nachinstallieren / aktualisieren
Falls der Befehl `winget` nicht gefunden wird (z.B. in frühen Windows 11 / 10 Versionen), muss der "App Installer" über den Store oder PowerShell erzwungen aktualisiert werden:
```powershell
# Variante 1: Winget / App Installer über PowerShell direkt aus dem Netz herunterladen und installieren
$progressPreference = 'silentlyContinue'
Invoke-WebRequest -Uri https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -OutFile .\winget.msixbundle
Add-AppxPackage .\winget.msixbundle
rm .\winget.msixbundle

# Variante 2: Microsoft Store zwingen, den App Installer sofort zu aktualisieren (Wartet im Hintergrund)
Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod
```

## 2. Winget Grundlagen```powershell
# Nach einer Software suchen
winget search "Firefox"

# Software stillschweigend (silent) installieren und EULA akzeptieren
winget install --id Mozilla.Firefox -e --accept-source-agreements --accept-package-agreements --silent

# Alle installierten Programme aktualisieren
winget upgrade --all --silent
```

## 3. Bulk-Installationen (JSON / YAML)

Winget unterstützt den Export und Import von Software-Listen, um einen neuen Rechner sofort einsatzbereit zu machen.

```powershell
# Die aktuelle Software-Liste als JSON exportieren
winget export -o C:\temp\software.json

# Software aus einer Liste gebündelt auf einem neuen Rechner installieren
winget import -i C:\temp\software.json --accept-source-agreements --accept-package-agreements
```

## 4. Windows Bloatware entfernen

Um Bloatware und vorinstallierte Apps bei einer Neuinstallation loszuwerden, kann PowerShell helfen.

```powershell
# Eine spezifische vorinstallierte App entfernen (z.B. TikTok)
Get-AppxPackage *tiktok* | Remove-AppxPackage

# Appx aus dem Windows-Image entfernen, damit sie bei neuen Benutzern nicht mehr auftaucht
Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*tiktok*" | Remove-AppxProvisionedPackage -Online

# Mehrere unerwünschte Apps auf einmal löschen
$bloatware = @(
    "*bing*",
    "*zunevideo*",
    "*solitaire*",
    "*xboxapp*"
)
foreach ($app in $bloatware) {
    Get-AppxPackage $app | Remove-AppxPackage
}
```

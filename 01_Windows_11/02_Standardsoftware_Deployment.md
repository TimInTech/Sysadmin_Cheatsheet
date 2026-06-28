# 02 Standardsoftware Deployment (Windows 11)

Windows 11 bringt den Paketmanager `winget` mit, der die Softwareverteilung revolutioniert.

## 1. Winget Grundlagen

```powershell
# Nach einer Software suchen
winget search "Firefox"

# Software stillschweigend (silent) installieren und EULA akzeptieren
winget install --id Mozilla.Firefox -e --accept-source-agreements --accept-package-agreements --silent

# Alle installierten Programme aktualisieren
winget upgrade --all --silent
```

## 2. Bulk-Installationen (JSON / YAML)

Winget unterstützt den Export und Import von Software-Listen, um einen neuen Rechner sofort einsatzbereit zu machen.

```powershell
# Die aktuelle Software-Liste als JSON exportieren
winget export -o C:\temp\software.json

# Software aus einer Liste gebündelt auf einem neuen Rechner installieren
winget import -i C:\temp\software.json --accept-source-agreements --accept-package-agreements
```

## 3. Windows Bloatware entfernen

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

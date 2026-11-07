# 12 Skript-Baukasten: Windows aufräumen, Datenschutz und Programme

Auf dieser Seite baust du dir ein eigenes, kleines PowerShell-Skript für einen frisch installierten Windows-Rechner. Du wählst selbst, welche Schritte laufen: Programme installieren, vorinstallierte Apps entfernen, zwei Datenschutz-Einstellungen setzen, Temp-Dateien löschen. Das Skript macht standardmäßig einen **Trockenlauf** und zeigt nur an, was es tun würde. Erst mit `-Ausfuehren` ändert es etwas.

> **Hinweis:** Das Skript wurde auf dem Linux-Testrechner **nicht ausgeführt** (kein Windows, keine PowerShell verfügbar). Die Registry-Werte sind gegen Microsoft Learn geprüft, das Skript selbst ist *nicht getestet*. Probiere es zuerst im Trockenlauf und in einer virtuellen Maschine aus.

> **Warnung:** Es gibt im Internet viele "Optimierungsskripte", die Dienste abschalten, Defender und Updates deaktivieren oder Systemdateien löschen. Das macht Rechner unsicher oder instabil. Dieses Skript hält sich bewusst zurück: Es setzt nur dokumentierte Einstellungen, entfernt nur Apps aus einer Liste, die du selbst pflegst, und legt vorher einen Wiederherstellungspunkt an.

## 1. Die Idee in einfachen Worten

Ein Baukasten besteht aus kleinen Bausteinen, die jeweils eine Sache tun und sich einzeln zurücknehmen lassen:

| Baustein | Was er tut | Rückgängig |
| --- | --- | --- |
| `Apps` | Installiert Programme aus einer winget-Liste | Programm normal deinstallieren |
| `Aufraeumen` | Entfernt vorinstallierte Apps aus deiner Liste (nur für dein Konto) | Aus dem Store neu installieren |
| `Datenschutz` | Diagnosedaten auf "erforderlich", Werbe-ID aus | Einstellungswerte entfernen (Abschnitt 5) |
| `Temp` | Löscht temporäre Dateien des Benutzers | nicht nötig |

Vorher: Wiederherstellungspunkt, Protokolldatei, Trockenlauf.

## 2. Vorbereitung

1. Aktuelle Updates einspielen: [Windows komplett aktualisieren](01_Update_und_Upgrade.md#1-nach-der-neuinstallation-alles-in-einem-durchlauf).
2. Programmliste bereitstellen. Du kannst [programme.winget.json](../11_Ersteinrichtung/programme.winget.json) kopieren und im selben Ordner wie `Skript-Baukasten.ps1` ablegen.
3. PowerShell **als Administrator** öffnen (Windows PowerShell, nicht PowerShell 7) und Skripte nur für dieses Fenster erlauben:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

Danach die Liste der installierten Apps ansehen, bevor du etwas entfernst:

```powershell
Get-AppxPackage | Select-Object Name | Sort-Object Name
```

## 3. Das Skript

Speichere den folgenden Inhalt als `Skript-Baukasten.ps1`. Die Liste `$EntfernenListe` ist absichtlich kurz. Entferne Einträge, die du behalten willst, und ergänze Namen aus der Ausgabe oben. Keine Namen von Windows-Komponenten wie `Microsoft.Windows.*`, `Microsoft.WindowsStore` oder `Microsoft.DesktopAppInstaller` eintragen: Diese braucht Windows.

```powershell
#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [ValidateSet('Apps', 'Aufraeumen', 'Datenschutz', 'Temp')]
    [string[]]$Schritte = @('Apps', 'Aufraeumen', 'Datenschutz', 'Temp'),
    [string]$AppListe = (Join-Path $PSScriptRoot 'programme.winget.json'),
    [switch]$Ausfuehren
)

# Apps, die entfernt werden duerfen (exakte Paketnamen, nur fuer das aktuelle Konto)
$EntfernenListe = @(
    'Microsoft.BingNews',
    'Microsoft.BingWeather',
    'Microsoft.MicrosoftSolitaireCollection',
    'Microsoft.GetHelp',
    'Microsoft.WindowsFeedbackHub',
    'Microsoft.MicrosoftOfficeHub'
)

# Protokoll und Trockenlauf
$LogOrdner = Join-Path $env:ProgramData 'Skript-Baukasten'
New-Item -ItemType Directory -Path $LogOrdner -Force | Out-Null
Start-Transcript -Path (Join-Path $LogOrdner ("log-{0:yyyyMMdd-HHmmss}.txt" -f (Get-Date))) | Out-Null

function Aktion {
    param([string]$Text, [scriptblock]$Code)
    if ($Ausfuehren) {
        Write-Host "TUN:         $Text"
        & $Code
    } else {
        Write-Host "TROCKENLAUF: $Text"
    }
}

if ($Ausfuehren) {
    try {
        Enable-ComputerRestore -Drive "$env:SystemDrive\"
        Checkpoint-Computer -Description 'Vor Skript-Baukasten' -RestorePointType MODIFY_SETTINGS
    } catch {
        Write-Warning "Wiederherstellungspunkt nicht moeglich: $($_.Exception.Message)"
        $antwort = Read-Host 'Trotzdem fortfahren? (j/n)'
        if ($antwort -ne 'j') { Stop-Transcript | Out-Null; return }
    }
}

foreach ($schritt in $Schritte) {
    switch ($schritt) {
        'Apps' {
            if (Test-Path $AppListe) {
                Aktion "Programme installieren aus $AppListe" {
                    winget import -i $AppListe --accept-source-agreements --accept-package-agreements
                }
            } else {
                Write-Warning "Programmliste nicht gefunden: $AppListe"
            }
        }
        'Aufraeumen' {
            foreach ($name in $EntfernenListe) {
                $paket = Get-AppxPackage -Name $name
                if ($paket) {
                    Aktion "App entfernen: $name" { $paket | Remove-AppxPackage }
                } else {
                    Write-Host "uebersprungen (nicht vorhanden): $name"
                }
            }
        }
        'Datenschutz' {
            Aktion 'Diagnosedaten auf "Erforderlich" setzen' {
                $pfad = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'
                New-Item -Path $pfad -Force | Out-Null
                Set-ItemProperty -Path $pfad -Name AllowTelemetry -Type DWord -Value 1
            }
            Aktion 'Werbe-ID fuer dieses Konto ausschalten' {
                $pfad = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
                New-Item -Path $pfad -Force | Out-Null
                Set-ItemProperty -Path $pfad -Name Enabled -Type DWord -Value 0
            }
        }
        'Temp' {
            Aktion "Temp-Dateien loeschen in $env:TEMP" {
                Get-ChildItem -Path $env:TEMP -Force -ErrorAction SilentlyContinue |
                    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

Stop-Transcript | Out-Null
if (-not $Ausfuehren) { Write-Host "`nNur Trockenlauf. Mit -Ausfuehren wirklich anwenden." }
```

## 4. Benutzen

```powershell
# 1. Trockenlauf: zeigt nur an, ändert nichts
.\Skript-Baukasten.ps1

# 2. Nur einzelne Bausteine, ebenfalls erst im Trockenlauf
.\Skript-Baukasten.ps1 -Schritte Aufraeumen, Datenschutz

# 3. Wirklich ausführen (Wiederherstellungspunkt wird vorher angelegt)
.\Skript-Baukasten.ps1 -Schritte Aufraeumen, Datenschutz -Ausfuehren
```

Das Protokoll liegt unter `C:\ProgramData\Skript-Baukasten`. Lies nach, was wirklich passiert ist.

Hinweise zu den Bausteinen:

- **Wiederherstellungspunkt:** Windows legt von sich aus höchstens alle 24 Stunden einen an. Gibt es schon einen, meldet das Skript eine Warnung und fragt nach. Er sichert Systemeinstellungen, **keine persönlichen Dateien**.
- **Diagnosedaten:** Der Wert `1` bedeutet "Erforderlich". Der Wert `0` ("Aus") wird laut [Microsoft](https://learn.microsoft.com/de-de/windows/client-management/mdm/policy-csp-system) nur in den Editionen Enterprise, Education und Server unterstützt, deshalb verwendet das Skript `1`. Unter Windows Home kann die Richtlinie wirkungslos sein.
- **Apps entfernen:** `Remove-AppxPackage` wirkt nur für dein Konto. Neue Benutzer bekommen die Apps weiterhin. Dokumentation: [Remove-AppxPackage](https://learn.microsoft.com/de-de/powershell/module/appx/remove-appxpackage).
- **Programme:** `winget import` ist unter [winget import](https://learn.microsoft.com/de-de/windows/package-manager/winget/import) beschrieben. Mehr in [Standardsoftware Deployment](02_Standardsoftware_Deployment.md).

## 5. Rückgängig machen

```powershell
# Datenschutz-Werte zurücknehmen
Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name AllowTelemetry -ErrorAction SilentlyContinue
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name Enabled -Type DWord -Value 1

# Eine entfernte App wieder holen (Beispiel: Wetter): im Microsoft Store suchen und installieren
winget search "MSN Wetter" --source msstore
```

Bei größeren Problemen: **Systemsteuerung -> Wiederherstellung -> Systemwiederherstellung öffnen** und den Punkt "Vor Skript-Baukasten" wählen. Weitere Reparaturwege: [Systemreparatur und Wartung](03_Systemreparatur_und_Wartung.md) und [Windows RE](../04_Rettungsmedien_und_Live_Systeme/03_Windows_RE.md).

## 6. Wer lieber klickt: winscript

Das Open-Source-Projekt [winscript](https://github.com/flick9000/winscript) (GPL-3.0) baut Windows-Skripte über eine Weboberfläche zusammen. Es deckt mehr ab als dieser Baukasten (Debloat, Datenschutz, Leistung, App-Installation). Wenn du so ein Skript verwendest:

- Lies das erzeugte Skript vollständig, bevor du es ausführst.
- Lege vorher einen Wiederherstellungspunkt an und teste in einer VM.
- Schalte nichts ab, dessen Zweck du nicht kennst (Defender, Windows Update, Firewall).

Auf dieser Seite ist **kein Code** aus winscript übernommen. Es ist nur als Alternative verlinkt, ungetestet.

## Quellen

- [Diagnosedaten (Richtlinie AllowTelemetry)](https://learn.microsoft.com/de-de/windows/client-management/mdm/policy-csp-system)
- [Verbindungen zu Microsoft-Diensten verwalten](https://learn.microsoft.com/de-de/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services)
- [Checkpoint-Computer](https://learn.microsoft.com/de-de/powershell/module/microsoft.powershell.management/checkpoint-computer)
- [Start-Transcript](https://learn.microsoft.com/de-de/powershell/module/microsoft.powershell.host/start-transcript)
- [Remove-AppxPackage](https://learn.microsoft.com/de-de/powershell/module/appx/remove-appxpackage)

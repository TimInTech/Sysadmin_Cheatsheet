function Invoke-SystemRepair {
    if (-not (Test-Admin)) { throw 'Bitte per Rechtsklick als Administrator ausfuehren.' }
    Write-Host 'Zuerst DISM-Diagnose. Fuer die nachfolgende Reparatur kann Internet erforderlich sein.'
    Invoke-NativeChecked "$env:WINDIR\System32\dism.exe" @('/Online','/Cleanup-Image','/CheckHealth')
    Write-Host 'DISM RestoreHealth und SFC koennen Systemdateien aendern und laengere Zeit dauern.'
    if ((Read-Host 'Reparatur ausfuehren? JA eingeben') -cne 'JA') {
        Write-Host 'Abgebrochen. Keine Reparatur ausgefuehrt.'
        return
    }
    Invoke-NativeChecked "$env:WINDIR\System32\dism.exe" @('/Online','/Cleanup-Image','/RestoreHealth')
    Invoke-NativeChecked "$env:WINDIR\System32\sfc.exe" @('/scannow')
}

# --- SSH repair -------------------------------------------------------------
# Each check returns an object: Name, Ok, Text (plain German), Fix (scriptblock
# or $null when only a hint is possible).

function New-SshFinding([string]$Name, [bool]$Ok, [string]$Text, [scriptblock]$Fix = $null) {
    [pscustomobject]@{ Name = $Name; Ok = $Ok; Text = $Text; Fix = $Fix }
}

function Get-SshPaths {
    @{
        Sshd       = "$env:WINDIR\System32\OpenSSH\sshd.exe"
        Keygen     = "$env:WINDIR\System32\OpenSSH\ssh-keygen.exe"
        Default    = "$env:WINDIR\System32\OpenSSH\sshd_config_default"
        Config     = "$env:ProgramData\ssh\sshd_config"
        AdminKeys  = "$env:ProgramData\ssh\administrators_authorized_keys"
        HostKey    = "$env:ProgramData\ssh\ssh_host_ed25519_key"
        Toolkit    = "$env:ProgramData\SysadminToolkit-RemoteHelp"
    }
}

function Get-SshCapabilityState { (Get-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0').State.ToString() }
function Get-SshServiceInfo { Get-CimInstance Win32_Service -Filter "Name='sshd'" -ErrorAction SilentlyContinue }
function Test-SshConfigValid([string]$Sshd) { & $Sshd -t 2>&1 | Out-Null; return ($LASTEXITCODE -eq 0) }
function Test-AdminKeysAcl([string]$Path) {
    # OpenSSH ignores administrators_authorized_keys unless only Administrators and SYSTEM have access.
    $acl = Get-Acl -LiteralPath $Path
    if (-not $acl.AreAccessRulesProtected) { return $false }
    foreach ($entry in $acl.Access) {
        $sid = $entry.IdentityReference.Translate([Security.Principal.SecurityIdentifier]).Value
        if ($sid -notin @('S-1-5-32-544', 'S-1-5-18')) { return $false }
    }
    return $true
}

function Get-SshFindings {
    $p = Get-SshPaths
    $findings = New-Object System.Collections.Generic.List[object]

    $state = Get-SshCapabilityState
    if ($state -ne 'Installed') {
        $findings.Add((New-SshFinding 'OpenSSH-Server' $false 'OpenSSH-Server ist nicht installiert. Behebung: von Windows nachladen (Internet noetig, einige Minuten). Die allgemeine Firewall-Freigabe, die Windows dabei anlegt, wird wieder entfernt; START_HIER legt eine Freigabe nur fuers Heimnetz an.' {
            $old = Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue
            try { Add-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0' | Out-Null }
            finally {
                if (-not $old) { Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue | Remove-NetFirewallRule }
            }
        }))
        # Everything below needs an installed server.
        return $findings
    }
    $findings.Add((New-SshFinding 'OpenSSH-Server' $true 'OpenSSH-Server ist installiert.'))

    if (-not (Test-Path -LiteralPath $p.HostKey)) {
        $findings.Add((New-SshFinding 'Hostschluessel' $false 'Der Schluessel, mit dem sich dieser Computer ausweist, fehlt. Behebung: neu erzeugen.' {
            & $p.Keygen -A
            if ($LASTEXITCODE -ne 0) { throw "ssh-keygen meldet Fehlercode $LASTEXITCODE." }
        }.GetNewClosure()))
    } else { $findings.Add((New-SshFinding 'Hostschluessel' $true 'Hostschluessel vorhanden.')) }

    if (-not (Test-Path -LiteralPath $p.Config)) {
        $findings.Add((New-SshFinding 'Konfiguration' $false 'Die SSH-Konfiguration fehlt. Behebung: Windows-Standardkonfiguration anlegen.' {
            New-Item -ItemType Directory -Path (Split-Path $p.Config) -Force | Out-Null
            Copy-Item -LiteralPath $p.Default -Destination $p.Config
        }.GetNewClosure()))
    } elseif (-not (Test-SshConfigValid $p.Sshd)) {
        $findings.Add((New-SshFinding 'Konfiguration' $false 'Die SSH-Konfiguration enthaelt Fehler, deshalb startet der Dienst nicht. Behebung: alte Datei als Sicherung umbenennen und die Windows-Standardkonfiguration einsetzen. Ein eingeschalteter Toolkit-Zugang funktioniert danach nicht mehr; dann STOP_HIER und START_HIER neu ausfuehren.' {
            $backup = '{0}.defekt-{1}' -f $p.Config, (Get-Date -Format 'yyyyMMdd-HHmmss')
            Copy-Item -LiteralPath $p.Config -Destination $backup
            Copy-Item -LiteralPath $p.Default -Destination $p.Config -Force
            Write-Host "   Sicherung der alten Datei: $backup"
        }.GetNewClosure()))
    } else { $findings.Add((New-SshFinding 'Konfiguration' $true 'SSH-Konfiguration ist fehlerfrei.')) }

    if ((Test-Path -LiteralPath $p.AdminKeys) -and -not (Test-AdminKeysAcl $p.AdminKeys)) {
        $findings.Add((New-SshFinding 'Schluesseldatei der Administratoren' $false 'administrators_authorized_keys hat zu offene Rechte; SSH ignoriert die Datei dann und Schluessel-Anmeldungen von Administratoren scheitern. Behebung: Rechte auf Administratoren und SYSTEM beschraenken (wie von Microsoft beschrieben).' {
            & "$env:WINDIR\System32\icacls.exe" $p.AdminKeys /inheritance:r /grant '*S-1-5-32-544:F' /grant '*S-1-5-18:F' | Out-Null
            if ($LASTEXITCODE -ne 0) { throw "icacls meldet Fehlercode $LASTEXITCODE." }
        }.GetNewClosure()))
    }

    $service = Get-SshServiceInfo
    if (-not $service) {
        $findings.Add((New-SshFinding 'SSH-Dienst' $false 'Der SSH-Dienst fehlt trotz Installation. Behebung nicht automatisch moeglich: OpenSSH-Server unter Einstellungen > System > Optionale Features entfernen und neu hinzufuegen.'))
    } else {
        if ($service.StartMode -eq 'Disabled') {
            $findings.Add((New-SshFinding 'Starttyp' $false 'Der SSH-Dienst ist deaktiviert. Behebung: auf "Manuell" stellen (startet nicht automatisch mit Windows).' {
                Set-Service -Name sshd -StartupType Manual
            }))
        }
        if ($service.State -ne 'Running') {
            $findings.Add((New-SshFinding 'SSH-Dienst' $false 'Der SSH-Dienst laeuft nicht. Behebung: starten. Hinweis: Danach koennen sich alle Konten mit SSH-Berechtigung anmelden, soweit die Firewall es zulaesst.' {
                Start-Service -Name sshd
            }))
        } else { $findings.Add((New-SshFinding 'SSH-Dienst' $true 'SSH-Dienst laeuft.')) }
    }

    if (Test-Path -LiteralPath $p.Toolkit) {
        if (Test-Path -LiteralPath (Join-Path $p.Toolkit 'owner.json')) {
            $findings.Add((New-SshFinding 'Toolkit-Zugang' $true 'Ein Toolkit-Zugang ist eingeschaltet. Ausschalten mit STOP_HIER.cmd.'))
        } else {
            $findings.Add((New-SshFinding 'Toolkit-Reste' $false 'Reste eines abgebrochenen START_HIER-Versuchs blockieren einen neuen Start. Behebung: die Reste entfernen.' {
                foreach ($file in @('SSH_EINRICHTEN.ps1', 'Gemeinsam.ps1', 'starttype.txt')) { Remove-Item -LiteralPath (Join-Path $p.Toolkit $file) -Force -ErrorAction SilentlyContinue }
                if (Get-ChildItem -LiteralPath $p.Toolkit -Force) { throw "Im Ordner $($p.Toolkit) liegen unbekannte Dateien; bitte von Hand pruefen." }
                Remove-Item -LiteralPath $p.Toolkit -Force
            }.GetNewClosure()))
        }
    }
    return $findings
}

function Write-SshFindings($Findings) {
    foreach ($finding in $Findings) {
        if ($finding.Ok) { Write-Host "   [OK] $($finding.Text)" -ForegroundColor Green }
        else { Write-Host "   [PROBLEM] $($finding.Name): $($finding.Text)" -ForegroundColor Yellow }
    }
}

# Returns the number of problems left after the run.
function Invoke-SshRepair {
    if (-not (Test-Admin)) { throw 'Bitte als Administrator ausfuehren.' }
    $changed = $false
    # Installing OpenSSH unlocks further checks, so up to two repair rounds plus a final check.
    for ($round = 1; $round -le 3; $round++) {
        Write-Host ''
        if ($round -eq 1) { Write-Host '>> SSH pruefen' -ForegroundColor Cyan } else { Write-Host '>> Kontrolle nach der Reparatur' -ForegroundColor Cyan }
        $findings = @(Get-SshFindings)
        Write-SshFindings $findings
        $problems = @($findings | Where-Object { -not $_.Ok })
        $fixable = @($problems | Where-Object { $_.Fix })
        $unchanged = ''
        if (-not $changed) { $unchanged = ' Es wurde nichts geaendert.' }
        Write-Host ''
        if (-not $problems.Count) {
            if ($changed) { Write-Host 'Reparatur erfolgreich. Alles in Ordnung.' -ForegroundColor Green }
            else { Write-Host 'Alles in Ordnung. Es wurde nichts geaendert.' -ForegroundColor Green }
            return 0
        }
        if (-not $fixable.Count -or $round -eq 3) {
            Write-Host ("{0} Problem(e) sind offen und nicht automatisch behebbar.{1} Bitte die Meldungen oben der helfenden Person schicken." -f $problems.Count, $unchanged) -ForegroundColor Yellow
            return $problems.Count
        }
        Write-Host "$($fixable.Count) Problem(e) koennen automatisch behoben werden (siehe 'Behebung' oben)."
        if ((Read-Host 'Jetzt beheben? JA eingeben (alles andere bricht ab)') -cne 'JA') {
            Write-Host "Abgebrochen.$unchanged"
            return $problems.Count
        }
        Write-Host ''
        Write-Host '>> Beheben' -ForegroundColor Cyan
        foreach ($finding in $fixable) {
            try { & $finding.Fix; Write-Host "   [BEHOBEN] $($finding.Name)" -ForegroundColor Green }
            catch { Write-Host "   [FEHLER] $($finding.Name): $($_.Exception.Message)" -ForegroundColor Red }
        }
        $changed = $true
    }
}

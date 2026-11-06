param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('SYSTEMINFO','SSH_REPARIEREN','WINDOWS_DIAGNOSE','SYSTEM_REPARIEREN','NETZWERK_DIAGNOSE')]
    [string]$Action
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\Repair.ps1"
function Show-Section([string]$Name, [scriptblock]$Command) {
    Write-Host "`n--- $Name ---"
    try { & $Command | Format-List | Out-Host }
    catch { Write-Warning "Nicht verfuegbar: $($_.Exception.Message)" }
}
function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
function Invoke-NativeChecked([string]$Program, [string[]]$Arguments) {
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Program meldet Fehlercode $LASTEXITCODE." }
}
switch ($Action) {
    'SYSTEMINFO' {
        Show-Section 'Windows' { Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,OSArchitecture,LastBootUpTime }
        Show-Section 'Hardware und RAM' { Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer,Model,TotalPhysicalMemory }
        Show-Section 'Prozessor' { Get-CimInstance Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors }
        Show-Section 'Laufwerke' { Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Select-Object DeviceID,FileSystem,Size,FreeSpace }
        Show-Section 'Netzwerk' { Get-NetIPConfiguration | Select-Object InterfaceAlias,IPv4Address,IPv4DefaultGateway,DNSServer }
    }
    'NETZWERK_DIAGNOSE' {
        Show-Section 'Netzwerkadapter' { Get-NetAdapter | Select-Object Name,Status,LinkSpeed,InterfaceDescription }
        Show-Section 'IP und DNS' { Get-NetIPConfiguration }
        Show-Section 'Netzwerkprofile' { Get-NetConnectionProfile }
        Show-Section 'Standardrouten' { Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0' | Select-Object InterfaceAlias,NextHop,RouteMetric }
        Show-Section 'DNS-Server' { Get-DnsClientServerAddress | Where-Object { $_.ServerAddresses.Count -gt 0 } | Select-Object InterfaceAlias,ServerAddresses }
        Write-Host 'DNS-Anfragen und Gateway-Erreichbarkeit muessen bei Bedarf mit den angezeigten lokalen Werten getestet werden.'
        Write-Host 'Es wurden keine Netzwerkeinstellungen geaendert.'
    }
    'WINDOWS_DIAGNOSE' {
        Show-Section 'Windows-Version' { Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,LastBootUpTime }
        foreach ($log in @('System','Application')) {
            Show-Section "${log}: Fehler der letzten sieben Tage" {
                $events = @(Get-WinEvent -FilterHashtable @{ LogName=$log; Level=1,2; StartTime=(Get-Date).AddDays(-7) } -MaxEvents 30 -ErrorAction SilentlyContinue)
                if ($events.Count -eq 0) { 'Keine passenden Ereignisse gefunden.' } else { $events | Select-Object TimeCreated,Id,ProviderName,Message }
            }
        }
        Show-Section 'Systemlaufwerk' { Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$env:SystemDrive'" | Select-Object DeviceID,Size,FreeSpace }
        Write-Host 'Diagnose abgeschlossen; keine Reparatur ausgefuehrt.'
    }
    'SSH_REPARIEREN' {
        Show-Section 'OpenSSH-Server-Feature' { Get-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0' }
        Show-Section 'SSH-Dienst' { Get-Service sshd }
        Show-Section 'SSH-Listener' { Get-NetTCPConnection -State Listen | Where-Object { $_.LocalPort -eq 22 } | Select-Object LocalAddress,LocalPort,OwningProcess }
        Show-Section 'Aktive Firewallregeln mit TCP-Port 22 oder beliebigem Port (auch nicht-SSH-Regeln)' {
            Get-NetFirewallRule -PolicyStore ActiveStore -Enabled True -Direction Inbound | ForEach-Object {
                $rule = $_; $port = $rule | Get-NetFirewallPortFilter
                if (($port.Protocol -in @('TCP','6','Any','256')) -and ($port.LocalPort -contains '22' -or $port.LocalPort -contains 'Any')) {
                    $address = $rule | Get-NetFirewallAddressFilter
                    [pscustomobject]@{ Name=$rule.Name; Action=$rule.Action; Profile=$rule.Profile; LocalPort=($port.LocalPort -join ','); RemoteAddress=($address.RemoteAddress -join ',') }
                }
            }
        }
        Show-Section 'SSH-Konfiguration pruefen' { & "$env:WINDIR\System32\OpenSSH\sshd.exe" -t; if ($LASTEXITCODE -ne 0) { throw "sshd -t: $LASTEXITCODE" }; 'Syntax gueltig' }
        Show-Section 'Effektive SSH-Authentifizierung (globale Standardwerte)' {
            & "$env:WINDIR\System32\OpenSSH\sshd.exe" -T | Where-Object { $_ -match '^(passwordauthentication|pubkeyauthentication|authenticationmethods|allowusers|denyusers|allowgroups|denygroups) ' }
            if ($LASTEXITCODE -ne 0) { throw "sshd -T: $LASTEXITCODE" }
            'Match-Regeln koennen je Benutzer und Quelladresse abweichen.'
        }
        Show-Section 'SSH-Ereignisse' { Get-WinEvent -LogName 'OpenSSH/Operational' -MaxEvents 20 | Select-Object TimeCreated,Id,Message }
        Write-Host 'Firewall- und Anmeldeprobleme bitte anhand der Ausgabe gezielt pruefen; keine Regeln werden geaendert.'
        $service = Get-Service sshd -ErrorAction SilentlyContinue
        if ($service -and $service.Status -eq 'Stopped' -and (Test-Admin)) {
            if ((Read-Host 'Gestoppten SSH-Dienst jetzt starten? JA eingeben') -ceq 'JA') {
                try { Start-Service sshd -ErrorAction Stop; Get-Service sshd | Format-List | Out-Host }
                catch { Write-Error "Dienst konnte nicht gestartet werden: $($_.Exception.Message)"; exit 1 }
            }
        }
    }
    'SYSTEM_REPARIEREN' {
        try { Invoke-SystemRepair } catch { Write-Error $_; exit 1 }
    }
}

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('SYSTEMINFO','SSH_REPARIEREN','WINDOWS_DIAGNOSE','SYSTEM_REPARIEREN','NETZWERK_DIAGNOSE')]
    [string]$Action,
    [switch]$Pause
)

$ErrorActionPreference = 'Stop'
$common = Join-Path (Split-Path $PSScriptRoot -Parent) 'Gemeinsam.ps1'
if (-not (Test-Path -LiteralPath $common)) {
    Write-Host 'FEHLER: Gemeinsam.ps1 fehlt. Bitte den ganzen Ordner "windows" mit dem Unterordner "zusatz" entpacken.' -ForegroundColor Red
    exit 1
}
. $common
. "$PSScriptRoot\Repair.ps1"

function Show-Section([string]$Name, [scriptblock]$Command) {
    Write-Host "`n--- $Name ---"
    try { & $Command | Format-List | Out-Host }
    catch { Write-Host "   Nicht verfuegbar: $($_.Exception.Message)" -ForegroundColor Yellow }
}
function Test-Admin { Test-ToolkitAdmin }
function Invoke-NativeChecked([string]$Program, [string[]]$Arguments) {
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Program meldet Fehlercode $LASTEXITCODE." }
}

# Repairs need elevation; start an elevated copy instead of failing with errors.
if ($Action -in @('SSH_REPARIEREN', 'SYSTEM_REPARIEREN')) {
    if (-not (Request-ToolkitAdmin -ScriptPath $PSCommandPath -Arguments @('-Action', $Action))) { exit 0 }
}

$exitCode = 0
try {
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
            Write-Host 'SSH pruefen und reparieren. Zuerst wird nur geprueft; geaendert wird erst nach Eingabe von JA.'
            $left = Invoke-SshRepair
            if ($left) { $exitCode = 1 }
        }
        'SYSTEM_REPARIEREN' {
            Invoke-SystemRepair
        }
    }
} catch {
    $exitCode = 1
    Write-ToolkitError -Was $_.Exception.Message -Tun 'Die Meldung abfotografieren oder abschreiben und der helfenden Person schicken.'
} finally {
    if ($Pause) { Wait-ToolkitExit }
}
exit $exitCode

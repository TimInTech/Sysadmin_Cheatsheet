param([ValidateSet('Start','Stop','Expire')][string]$Action = 'Start')
if ($Action -eq 'Start') {
    throw 'Der Windows-SSH-Schnellstart ist aus Sicherheitsgruenden deaktiviert. Ablauf und Rueckbau sind noch nicht ausreichend verifiziert.'
}
$ErrorActionPreference = 'Stop'
$root = Join-Path $env:ProgramData 'SysadminToolkitRemoteHelp'
$statePath = Join-Path $root 'state.json'
$ownedInstall = Join-Path $root 'installed-by-toolkit'
$taskName = 'SysadminToolkitRemoteHelpCleanup'
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Bitte per Rechtsklick als Administrator ausfuehren.'
}
. "$PSScriptRoot\State.ps1"
function Save-State($State) { Write-AtomicState -Path $statePath -State $State }
function Stop-RemoteHelp {
    if (-not (Test-Path -LiteralPath $statePath)) { Write-Host 'Kein Toolkit-Zugang gefunden.'; return }
    $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
    if ($state.UserName -and -not $state.UserSid -and $state.UserMarker) {
        $candidate = Get-LocalUser -Name $state.UserName -ErrorAction SilentlyContinue
        if ($candidate -and $candidate.Description -ceq $state.UserMarker) { $state.UserSid = $candidate.SID.Value }
    }
    # A SID comparison protects a replacement account with the same name.
    if ($state.UserName -and $state.UserSid) {
        $user = Get-LocalUser -Name $state.UserName -ErrorAction SilentlyContinue
        if ($user -and $user.SID.Value -eq $state.UserSid) { Disable-LocalUser -SID $user.SID }
    }
    if ($state.SupervisorTask) {
        $task = Get-ScheduledTask -TaskName $state.SupervisorTask -TaskPath '\' -ErrorAction SilentlyContinue
        if ($task) {
            if (@($task.Actions).Count -ne 1 -or $task.Actions[0].Execute -ine $state.SupervisorExecutable -or $task.Actions[0].Arguments -cne $state.SupervisorArguments) {
                throw 'Die Supervisor-Aufgabe wurde fremd geaendert. Kein automatischer Rueckbau.'
            }
            if ($task.State -eq 'Running') { Stop-ScheduledTask -InputObject $task -ErrorAction Stop }
            Unregister-ScheduledTask -InputObject $task -Confirm:$false -ErrorAction Stop
        }
    }
    if ($state.ProcessId -and $state.ProcessStart) {
        $process = Get-Process -Id $state.ProcessId -ErrorAction SilentlyContinue
        if ($process -and $process.ProcessName -eq 'sshd' -and $process.StartTime.ToUniversalTime().ToString('o') -eq $state.ProcessStart) {
            & "$env:WINDIR\System32\taskkill.exe" /PID $process.Id /T /F | Out-Null
            if ($LASTEXITCODE -ne 0) { throw 'Der eigene SSH-Prozessbaum konnte nicht beendet werden.' }
        }
    }
    if ($state.FirewallName) { Get-NetFirewallRule -Name $state.FirewallName -ErrorAction SilentlyContinue | Remove-NetFirewallRule }
    if ($state.UserName -and $state.UserSid) {
        $user = Get-LocalUser -Name $state.UserName -ErrorAction SilentlyContinue
        if ($user -and $user.SID.Value -eq $state.UserSid) { Remove-LocalUser -SID $user.SID }
    }
    $cleanupTask = Get-ScheduledTask -TaskName $taskName -TaskPath '\' -ErrorAction SilentlyContinue
    if ($cleanupTask) {
        if (@($cleanupTask.Actions).Count -ne 1 -or $cleanupTask.Actions[0].Execute -ine $state.CleanupExecutable -or $cleanupTask.Actions[0].Arguments -cne $state.CleanupArguments) {
            throw 'Die Ablauf-Aufgabe wurde fremd geaendert. Kein automatischer Rueckbau.'
        }
        Unregister-ScheduledTask -InputObject $cleanupTask -Confirm:$false -ErrorAction Stop
    }
    Remove-Item -LiteralPath $statePath -Force
    foreach ($file in @('RemoteHelp.ps1','State.ps1','SshSupervisor.ps1','JobSupervisor.cs','supervisor.json','ready.json','intent-account.json','intent-firewall.json','intent-supervisor-task.json','sshd_config','ssh_host_ed25519_key','ssh_host_ed25519_key.pub')) {
        Remove-Item -LiteralPath (Join-Path $root $file) -Force -ErrorAction SilentlyContinue
    }
    if (-not (Test-Path -LiteralPath $ownedInstall)) { Remove-Item -LiteralPath $root -Force -ErrorAction SilentlyContinue }
    Write-Host 'Konto deaktiviert und eigene Regel entfernt. Bestehende SSH-Konfiguration blieb unveraendert.'
}
$mutex = New-Object System.Threading.Mutex($false, 'Global\SysadminToolkitRemoteHelp')
$mutexHeld = $false
try {
    try { $mutexHeld = $mutex.WaitOne() }
    catch [System.Threading.AbandonedMutexException] { $mutexHeld = $true }
if ($Action -ne 'Start') { Stop-RemoteHelp; return }
if (Test-Path -LiteralPath $statePath) { throw 'Ein Toolkit-Zugang existiert bereits. Erst STOP_HIER ausfuehren.' }
$service = Get-CimInstance Win32_Service -Filter "Name='sshd'" -ErrorAction SilentlyContinue
if ($service -and (-not (Test-Path -LiteralPath $ownedInstall) -or $service.StartMode -ne 'Disabled' -or $service.State -ne 'Stopped')) {
    throw 'Ein vorhandener SSH-Dienst kann das neue Konto ebenfalls anmelden. Sicherheitsabbruch ohne Aenderung.'
}
if (Get-Process sshd -ErrorAction SilentlyContinue) { throw 'Ein SSH-Server laeuft bereits. Sicherheitsabbruch ohne Aenderung.' }
if (Get-NetTCPConnection -State Listen -LocalPort 22 -ErrorAction SilentlyContinue) { throw 'Port 22 wird bereits verwendet. Sicherheitsabbruch ohne Aenderung.' }
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) { throw 'Eine gleichnamige geplante Aufgabe existiert bereits. Sicherheitsabbruch.' }
. "$PSScriptRoot\SshHelpers.ps1"
$addresses = @(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } | ForEach-Object {
    try {
        $subnet = Get-PrivateSubnet $_.IPAddress $_.PrefixLength
        $adapter = Get-NetAdapter -InterfaceIndex $_.InterfaceIndex -ErrorAction Stop
        if ($adapter.Status -eq 'Up' -and $adapter.HardwareInterface) { [pscustomobject]@{ IP=$_.IPAddress; Subnet=$subnet; Adapter=$adapter.Name } }
    } catch { }
})
if ($addresses.Count -eq 0) { throw 'Kein aktiver physischer Adapter mit privater IPv4-Adresse gefunden.' }
for ($i=0; $i -lt $addresses.Count; $i++) { Write-Host ("{0}: {1} {2} ({3})" -f ($i+1),$addresses[$i].Adapter,$addresses[$i].IP,$addresses[$i].Subnet) }
$selection = 0
if (-not [int]::TryParse((Read-Host 'Nummer des LAN-Adapters'), [ref]$selection) -or $selection -lt 1 -or $selection -gt $addresses.Count) { throw 'Ungueltige Auswahl.' }
$selected = $addresses[$selection-1]
Write-Host 'Es wird ein Standardkonto fuer zwei Stunden und eine LAN-begrenzte SSH-Instanz erstellt.'
if ((Read-Host 'Fortfahren? JA eingeben') -cne 'JA') { return }
if ((Test-Path -LiteralPath $root) -and -not (Test-Path -LiteralPath $ownedInstall)) { throw 'Das Toolkit-Datenverzeichnis existiert bereits. Bitte vorher pruefen und bereinigen.' }
if (-not (Test-Path -LiteralPath $root)) { New-Item -ItemType Directory -Path $root | Out-Null }
$acl = New-Object System.Security.AccessControl.DirectorySecurity
$acl.SetAccessRuleProtection($true, $false)
foreach ($sid in @('S-1-5-18','S-1-5-32-544')) {
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule((New-Object System.Security.Principal.SecurityIdentifier($sid)), 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
    $acl.AddAccessRule($rule)
}
Set-Acl -LiteralPath $root -AclObject $acl
Copy-Item -LiteralPath $PSCommandPath -Destination (Join-Path $root 'RemoteHelp.ps1')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'State.ps1') -Destination (Join-Path $root 'State.ps1')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'SshSupervisor.ps1') -Destination (Join-Path $root 'SshSupervisor.ps1')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'JobSupervisor.cs') -Destination (Join-Path $root 'JobSupervisor.cs')
$state = [ordered]@{ UserName=''; UserSid=''; UserMarker=''; FirewallName=''; ProcessId=0; ProcessStart=''; SupervisorTask=''; SupervisorExecutable=''; SupervisorArguments=''; CleanupExecutable=''; CleanupArguments='' }
Save-State $state
try {
    $expires = (Get-Date).AddHours(2)
    $state.CleanupExecutable = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
    $state.CleanupArguments = "-NoProfile -ExecutionPolicy Bypass -File `"$root\RemoteHelp.ps1`" -Action Expire"
    Save-State $state
    $cleanup = New-ScheduledTaskAction -Execute $state.CleanupExecutable -Argument $state.CleanupArguments
    $triggers = @((New-ScheduledTaskTrigger -Once -At $expires),(New-ScheduledTaskTrigger -AtStartup))
    Register-ScheduledTask -TaskName $taskName -Action $cleanup -Trigger $triggers -User 'SYSTEM' -RunLevel Highest | Out-Null
    $cap = Get-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0'
    if ($cap.State -ne 'Installed') {
        $oldRule = Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue
        Add-WindowsCapability -Online -Name $cap.Name | Out-Null
        if (-not $oldRule) {
            $newRule = Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue
            if ($newRule) { Remove-NetFirewallRule -InputObject $newRule }
        }
        Set-Content -LiteralPath $ownedInstall -Value 'OpenSSH installed by Sysadmin Toolkit' -Encoding ASCII
    }
    Set-Service sshd -StartupType Disabled
    $name = 'remotehelp'; $index = 0
    while (Get-LocalUser -Name $name -ErrorAction SilentlyContinue) { $index++; $name = "remotehelp$index"; if ($index -gt 99) { throw 'Kein freier Kontoname.' } }
    $state.UserName = $name; $state.UserMarker = 'SysadminToolkit-' + [guid]::NewGuid().ToString('N'); Save-State $state
    $accountIntent = Join-Path $root 'intent-account.json'
    Set-ResourceIntent -Path $accountIntent -Kind account -Identity $name -Marker $state.UserMarker
    $alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789'
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    $password = ''; $buffer = New-Object byte[] 1
    try {
        do {
            $password = ''
            while ($password.Length -lt 20) {
            $rng.GetBytes($buffer)
            if ($buffer[0] -lt (256 - (256 % $alphabet.Length))) { $password += $alphabet[$buffer[0] % $alphabet.Length] }
            }
        } until ($password -cmatch '[A-Z]' -and $password -cmatch '[a-z]' -and $password -match '[0-9]')
    } finally { $rng.Dispose() }
    $password += '!'
    $securePassword = New-Object Security.SecureString
    foreach ($character in $password.ToCharArray()) { $securePassword.AppendChar($character) }
    $securePassword.MakeReadOnly()
    $user = New-LocalUser -Name $name -Password $securePassword -AccountExpires $expires -Description $state.UserMarker
    $securePassword.Dispose()
    $state.UserName = $name; $state.UserSid = $user.SID.Value; Save-State $state
    Set-ResourceApplied -Path $accountIntent -Identity $name
    $key = Join-Path $root 'ssh_host_ed25519_key'
    & "$env:WINDIR\System32\OpenSSH\ssh-keygen.exe" -q -t ed25519 -N '""' -f $key
    if ($LASTEXITCODE -ne 0) { throw 'SSH-Hostschluessel konnte nicht erstellt werden.' }
    $port = 22422
    if (Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue) { throw 'Der Toolkit-Port 22422 ist bereits belegt.' }
    $config = Join-Path $root 'sshd_config'
    @("Port $port", "ListenAddress $($selected.IP)", "HostKey $($key.Replace('\','/'))", "AllowUsers $name@$($selected.Subnet)", 'PasswordAuthentication yes', 'PubkeyAuthentication no', 'PermitEmptyPasswords no') | Set-Content -LiteralPath $config -Encoding ASCII
    $exe = "$env:WINDIR\System32\OpenSSH\sshd.exe"
    & $exe -t -f $config
    if ($LASTEXITCODE -ne 0) { throw 'SSH-Konfiguration ist ungueltig.' }
    $state.FirewallName = 'SysadminToolkitRemoteHelp-' + [guid]::NewGuid().ToString('N'); Save-State $state
    $firewallIntent = Join-Path $root 'intent-firewall.json'
    Set-ResourceIntent -Path $firewallIntent -Kind firewall -Identity $state.FirewallName -Marker $state.UserMarker
    New-NetFirewallRule -Name $state.FirewallName -DisplayName 'Sysadmin Toolkit Remote Help' -Direction Inbound -Action Allow -Protocol TCP -LocalPort $port -LocalAddress $selected.IP -RemoteAddress $selected.Subnet | Out-Null
    Set-ResourceApplied -Path $firewallIntent -Identity $state.FirewallName
    $supervisorState = Join-Path $root 'supervisor.json'
    $ready = Join-Path $root 'ready.json'
    Write-AtomicState -Path $supervisorState -State @{ Executable=$exe; Arguments="-D -f `"$config`""; DeadlineUtc=$expires.ToUniversalTime().ToString('o'); ReadyPath=$ready }
    $state.SupervisorTask = 'SysadminToolkitSupervisor-' + [guid]::NewGuid().ToString('N')
    $state.SupervisorExecutable = $state.CleanupExecutable
    $state.SupervisorArguments = "-NoProfile -ExecutionPolicy Bypass -File `"$root\SshSupervisor.ps1`" -StatePath `"$supervisorState`""
    Save-State $state
    $taskIntent = Join-Path $root 'intent-supervisor-task.json'
    Set-ResourceIntent -Path $taskIntent -Kind task -Identity $state.SupervisorTask -Marker $state.UserMarker
    $supervisorAction = New-ScheduledTaskAction -Execute $state.SupervisorExecutable -Argument $state.SupervisorArguments
    Register-ScheduledTask -TaskName $state.SupervisorTask -Action $supervisorAction -User 'SYSTEM' -RunLevel Highest | Out-Null
    Set-ResourceApplied -Path $taskIntent -Identity $state.SupervisorTask
    Start-ScheduledTask -TaskName $state.SupervisorTask
    $startLimit = (Get-Date).AddSeconds(20)
    while (-not (Test-Path -LiteralPath $ready) -and (Get-Date) -lt $startLimit) { Start-Sleep -Milliseconds 200 }
    if (-not (Test-Path -LiteralPath $ready)) { throw 'Der ueberwachte SSH-Prozess meldete sich nicht rechtzeitig.' }
    $processId = [int](Get-Content -LiteralPath $ready -Raw | ConvertFrom-Json).ProcessId
    $process = Get-Process -Id $processId -ErrorAction Stop
    $state.ProcessId = $process.Id; $state.ProcessStart = $process.StartTime.ToUniversalTime().ToString('o'); Save-State $state
    $mutex.ReleaseMutex(); $mutexHeld = $false
    Add-Type -AssemblyName System.Windows.Forms
    $fingerprint = (& "$env:WINDIR\System32\OpenSSH\ssh-keygen.exe" -lf "$key.pub") -join ' '
    [void][Windows.Forms.MessageBox]::Show("IP: $($selected.IP)`nBenutzer: $name`nPasswort: $password`nSSH: ssh -p $port $name@$($selected.IP)`nHostkey: $fingerprint`nAblauf: $expires`n`nPasswort wird nicht gespeichert.", 'Remote Help', 'OK', 'Information')
} catch {
    Write-Warning "Einrichtung fehlgeschlagen: $($_.Exception.Message)"
    try {
        if (-not $mutexHeld) {
            try { $mutexHeld = $mutex.WaitOne() }
            catch [System.Threading.AbandonedMutexException] { $mutexHeld = $true }
        }
        Stop-RemoteHelp
    } catch { Write-Warning "Rueckbau fehlgeschlagen: $($_.Exception.Message). STOP_HIER erneut als Administrator ausfuehren." }
    throw
}
} finally {
    if ($mutexHeld) { $mutex.ReleaseMutex() }
    $mutex.Dispose()
}

param([switch]$Stop)
$ErrorActionPreference = 'Stop'
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not ([Security.Principal.WindowsPrincipal]$identity).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Bitte als Administrator ausfuehren.'
}
$rule = 'SysadminToolkit-RemoteHelp'
$task = 'SysadminToolkit-RemoteHelp-Stop'
$folder = Join-Path $env:ProgramData 'SysadminToolkit-RemoteHelp'
$ownerPath = Join-Path $folder 'owner.json'
$config = Join-Path $env:ProgramData 'ssh\sshd_config'
$sshd = Join-Path $env:WINDIR 'System32\OpenSSH\sshd.exe'
$owner = $null
if ($Stop) {
    if (-not (Test-Path -LiteralPath $ownerPath)) { Write-Host 'Kein Toolkit-Zugang gefunden.'; return }
    $owner = Get-Content -LiteralPath $ownerPath -Raw | ConvertFrom-Json
    if ($owner.token -notmatch '^[0-9a-f]{32}$' -or $owner.name -notmatch '^remotehelp[0-9]*$') { throw 'Toolkit-Metadaten ungueltig; bitte manuell pruefen.' }
    $token = $owner.token
} else { $token = [guid]::NewGuid().ToString('N') }
$marker = "SysadminToolkit-$token"
$begin = "# BEGIN SYSADMIN TOOLKIT REMOTEHELP $token"
$end = "# END SYSADMIN TOOLKIT REMOTEHELP $token"

function Remove-ConfigBlock {
    if (-not (Test-Path -LiteralPath $config)) { return }
    $bytes = [IO.File]::ReadAllBytes($config)
    if (@($bytes | Where-Object { $_ -gt 127 }).Count) { throw 'SSH-Konfiguration enthaelt Nicht-ASCII-Zeichen; bitte manuell pruefen.' }
    $text = [Text.Encoding]::ASCII.GetString($bytes)
    $start = $text.IndexOf($begin, [StringComparison]::Ordinal)
    $finish = $text.IndexOf($end, [StringComparison]::Ordinal)
    if ($start -lt 0 -and $finish -lt 0) { return }
    if ($start -lt 0 -or $finish -lt $start -or $text.IndexOf($begin, $start + $begin.Length, [StringComparison]::Ordinal) -ge 0 -or $text.IndexOf($end, $finish + $end.Length, [StringComparison]::Ordinal) -ge 0) { throw 'SSH-Markierungen sind unvollstaendig oder mehrfach vorhanden; bitte manuell pruefen.' }
    $finish += $end.Length
    if ($text.Substring($finish).StartsWith("`r`n")) { $finish += 2 }
    elseif ($text.Substring($finish).StartsWith("`n")) { $finish++ }
    [IO.File]::WriteAllBytes($config, [Text.Encoding]::ASCII.GetBytes($text.Remove($start, $finish - $start)))
}
function Stop-Access {
    if (-not $owner) { Write-Host 'Kein Toolkit-Zugang gefunden.'; return }
    $user = Get-LocalUser -Name $owner.name -ErrorAction SilentlyContinue
    if ($user -and ($user.Description -cne $marker -or ($owner.sid -and $user.SID.Value -ne $owner.sid))) { throw 'Benutzeridentitaet stimmt nicht; keine Aenderung.' }
    $existingRule = Get-NetFirewallRule -Name $rule -ErrorAction SilentlyContinue
    $existingTask = Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
    $hasBlock = (Test-Path -LiteralPath $config) -and ([IO.File]::ReadAllText($config).Contains($begin))
    if ($user) { Disable-LocalUser -SID $user.SID }
    if (Test-Path $sshd) {
        Remove-ConfigBlock
        & $sshd -t
        if ($LASTEXITCODE -ne 0) { throw 'SSH-Konfiguration nach Entfernen der Markierung ungueltig; bitte pruefen.' }
        if ((Get-Service sshd -ErrorAction SilentlyContinue).Status -eq 'Running') {
            if ($owner.started) { Stop-Service sshd } else { Restart-Service sshd }
        }
    }
    if ($existingRule -and $existingRule.DisplayName -eq $marker) { $existingRule | Remove-NetFirewallRule }
    if ($user) { Remove-LocalUser -SID $user.SID }
    if ($existingTask -and $existingTask.Description -eq $marker) { Unregister-ScheduledTask -TaskName $task -Confirm:$false }
    $previousStart = Join-Path $folder 'starttype.txt'
    if (Test-Path -LiteralPath $previousStart) {
        $previous = (Get-Content -LiteralPath $previousStart -Raw).Trim()
        $serviceInfo = Get-CimInstance Win32_Service -Filter "Name='sshd'" -ErrorAction SilentlyContinue
        if ($serviceInfo -and $serviceInfo.StartMode -eq 'Auto' -and $previous -in @('Manual','Disabled')) { Set-Service sshd -StartupType $previous }
        Remove-Item -LiteralPath $previousStart -Force
    }
    Remove-Item -LiteralPath (Join-Path $folder 'SSH_EINRICHTEN.ps1') -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $ownerPath -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $folder) { Remove-Item -LiteralPath $folder -Force -ErrorAction SilentlyContinue }
    Write-Host 'Der Toolkit-Zugang wurde entfernt. SSH-Dienst und installierte Pakete bleiben erhalten.'
}
if ($Stop) { Stop-Access; return }
if ((Get-NetFirewallRule -Name $rule -ErrorAction SilentlyContinue) -or (Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue)) { throw 'Ein Toolkit-Zugang oder gleichnamige Ressource existiert bereits. Bitte zuerst STOP_HIER ausfuehren.' }
if (Test-Path -LiteralPath $folder) { throw 'Das Toolkit-Verzeichnis ist bereits vorhanden; bitte vorher pruefen oder STOP_HIER ausfuehren.' }
if ((Test-Path $config) -and ([IO.File]::ReadAllText($config).Contains('# BEGIN SYSADMIN TOOLKIT REMOTEHELP'))) { throw 'Toolkit-Markierung bereits vorhanden. Bitte zuerst STOP_HIER ausfuehren.' }
$addresses = @(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' -and $_.PrefixLength -ge 16 -and $_.PrefixLength -le 30 } | ForEach-Object {
    $ip = $_
    $adapter = Get-NetAdapter -InterfaceIndex $ip.InterfaceIndex -ErrorAction SilentlyContinue
    $parts = $ip.IPAddress.Split('.') | ForEach-Object { [int]$_ }
    if ($adapter -and $adapter.Status -eq 'Up' -and $adapter.HardwareInterface -and ($parts[0] -eq 10 -or ($parts[0] -eq 172 -and $parts[1] -ge 16 -and $parts[1] -le 31) -or ($parts[0] -eq 192 -and $parts[1] -eq 168))) {
        $raw = [Net.IPAddress]::Parse($ip.IPAddress).GetAddressBytes(); [array]::Reverse($raw)
        $number = [BitConverter]::ToUInt32($raw,0)
        $mask = [uint32]([uint64]0xffffffffL -shl (32 - $ip.PrefixLength) -band [uint64]0xffffffffL)
        $networkBytes = [BitConverter]::GetBytes([uint32]($number -band $mask)); [array]::Reverse($networkBytes)
        [pscustomobject]@{ IP=$ip.IPAddress; Network=([Net.IPAddress]::new($networkBytes).ToString() + '/' + $ip.PrefixLength); Adapter=$adapter.Name }
    }
})
if (-not $addresses.Count) { throw 'Kein geeignetes physisches privates IPv4-Netz gefunden.' }
for ($i=0; $i -lt $addresses.Count; $i++) { Write-Host ("{0}) {1}: {2} ({3})" -f ($i+1),$addresses[$i].Adapter,$addresses[$i].IP,$addresses[$i].Network) }
$selection = 0
if (-not [int]::TryParse((Read-Host 'Netznummer'), [ref]$selection) -or $selection -lt 1 -or $selection -gt $addresses.Count) { throw 'Ungueltige Netznummer.' }
$selected = $addresses[$selection-1]
$mode = (Read-Host '1 = temporaer (2 Stunden), 2 = dauerhaft').Trim()
if ($mode -notin @('1','2')) { throw 'Ungueltige Auswahl.' }
$name = 'remotehelp'; $suffix = 0
while (Get-LocalUser -Name $name -ErrorAction SilentlyContinue) { $suffix++; $name = "remotehelp$suffix"; if ($suffix -gt 99) { throw 'Kein freier Benutzername.' } }
$alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789'
$rng = [Security.Cryptography.RandomNumberGenerator]::Create(); $buffer = New-Object byte[] 1; $password = ''
try { while ($password.Length -lt 16) { $rng.GetBytes($buffer); if ($buffer[0] -lt (256 - 256 % $alphabet.Length)) { $password += $alphabet[$buffer[0] % $alphabet.Length] } } } finally { $rng.Dispose() }
$password += 'aA1!'
try {
    New-Item -ItemType Directory -Path $folder | Out-Null
    $acl = New-Object System.Security.AccessControl.DirectorySecurity
    $acl.SetAccessRuleProtection($true, $false)
    foreach ($sid in @('S-1-5-18','S-1-5-32-544')) {
        $access = New-Object System.Security.AccessControl.FileSystemAccessRule((New-Object System.Security.Principal.SecurityIdentifier($sid)), 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
        $acl.AddAccessRule($access)
    }
    Set-Acl -LiteralPath $folder -AclObject $acl
    $owner = [pscustomobject]@{ token=$token; name=$name; sid=''; started=$false }
    $owner | ConvertTo-Json | Set-Content -LiteralPath $ownerPath -Encoding UTF8
    Copy-Item -LiteralPath $PSCommandPath -Destination (Join-Path $folder 'SSH_EINRICHTEN.ps1') -Force
    $cap = Get-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0'
    if ($cap.State -ne 'Installed') {
        $oldRule = Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue
        try { Add-WindowsCapability -Online -Name $cap.Name | Out-Null }
        finally {
            if (-not $oldRule) {
                $newRule = Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue
                if ($newRule) { $newRule | Remove-NetFirewallRule }
            }
        }
    }
    if (-not (Test-Path $config)) {
        New-Item -ItemType Directory -Path (Split-Path $config) -Force | Out-Null
        Copy-Item (Join-Path $env:WINDIR 'System32\OpenSSH\sshd_config_default') $config
    }
    $bytes = [IO.File]::ReadAllBytes($config)
    if (@($bytes | Where-Object { $_ -gt 127 }).Count) { throw 'SSH-Konfiguration enthaelt Nicht-ASCII-Zeichen. Keine automatische Aenderung.' }
    $lines = [IO.File]::ReadAllLines($config)
    foreach ($line in $lines) {
        if ($line -match '^\s*Include\s+' -or ($line -match '^\s*Match\s+' -and $line -notmatch '^\s*Match\s+Group\s+administrators\s*(#.*)?$')) {
            throw 'Bestehende Match-/Include-Regeln koennen die Netzbegrenzung beeinflussen. Bitte SSH-Konfiguration manuell pruefen.'
        }
    }
    & (Join-Path $env:WINDIR 'System32\OpenSSH\ssh-keygen.exe') -A
    if ($LASTEXITCODE -ne 0) { throw 'SSH-Hostschluessel konnten nicht geprueft werden.' }
    $secure = New-Object Security.SecureString
    foreach ($character in $password.ToCharArray()) { $secure.AppendChar($character) }
    $secure.MakeReadOnly()
    $params = @{Name=$name; Password=$secure; Description=$marker; Disabled=$true}
    if ($mode -eq '1') { $params.AccountExpires = (Get-Date).AddHours(2) }
    $newUser = New-LocalUser @params
    $owner.sid = $newUser.SID.Value
    $owner | ConvertTo-Json | Set-Content -LiteralPath $ownerPath -Encoding UTF8
    $secure.Dispose()
    $block = "`r`n$begin`r`nMatch User $name,.\$name Address !$($selected.Network),*`r`n    DenyUsers $name .\$name`r`n    PasswordAuthentication no`r`n    PubkeyAuthentication no`r`nMatch User $name,.\$name Address $($selected.Network)`r`n    PasswordAuthentication yes`r`n    PubkeyAuthentication no`r`n    PermitEmptyPasswords no`r`n$end`r`n"
    [IO.File]::AppendAllText($config, $block, [Text.Encoding]::ASCII)
    & $sshd -t
    if ($LASTEXITCODE -ne 0) { throw 'SSH-Konfiguration ungueltig.' }
    $inside = & $sshd -T -C "user=.\$name,host=localhost,addr=$($selected.IP)"
    if ($LASTEXITCODE -ne 0 -or $inside -notcontains 'passwordauthentication yes') { throw 'Passwortanmeldung fuer das gewaehlte Netz nicht wirksam.' }
    $outside = & $sshd -T -C "user=.\$name,host=localhost,addr=8.8.8.8"
    if ($LASTEXITCODE -ne 0 -or $outside -notcontains "denyusers $name" -or $outside -notcontains 'passwordauthentication no' -or $outside -notcontains 'pubkeyauthentication no') { throw 'Zugang ausserhalb des gewaehlten Netzes nicht sicher gesperrt.' }
    $outside6 = & $sshd -T -C "user=.\$name,host=localhost,addr=2001:db8::1"
    if ($LASTEXITCODE -ne 0 -or $outside6 -notcontains "denyusers $name" -or $outside6 -notcontains 'passwordauthentication no' -or $outside6 -notcontains 'pubkeyauthentication no') { throw 'IPv6-Zugang nicht sicher gesperrt.' }
    $portLine = @($inside | Where-Object { $_ -match '^port [0-9]+$' } | Select-Object -First 1)
    if (-not $portLine.Count) { throw 'SSH-Port konnte nicht ermittelt werden.' }
    $port = [int]($portLine[0] -replace '^port ', '')
    New-NetFirewallRule -Name $rule -DisplayName $marker -Direction Inbound -Action Allow -Protocol TCP -LocalPort $port -LocalAddress $selected.IP -RemoteAddress $selected.Network | Out-Null
    $serviceInfo = Get-CimInstance Win32_Service -Filter "Name='sshd'"
    if ($mode -eq '2' -and $serviceInfo.StartMode -ne 'Auto') {
        Set-Content -LiteralPath (Join-Path $folder 'starttype.txt') -Value $serviceInfo.StartMode -Encoding ASCII
        Set-Service sshd -StartupType Automatic
    } elseif ($serviceInfo.StartMode -eq 'Disabled') {
        throw 'Der vorhandene SSH-Dienst ist deaktiviert; bitte seinen Starttyp vorab pruefen.'
    }
    if ($mode -eq '1') {
        $action = New-ScheduledTaskAction -Execute "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$folder\SSH_EINRICHTEN.ps1`" -Stop"
        $triggers = @((New-ScheduledTaskTrigger -Once -At $params.AccountExpires),(New-ScheduledTaskTrigger -AtStartup))
        Register-ScheduledTask -TaskName $task -Description $marker -Action $action -Trigger $triggers -User 'SYSTEM' -RunLevel Highest | Out-Null
    }
    $service = Get-Service sshd
    $owner.started = $service.Status -ne 'Running'
    $owner | ConvertTo-Json | Set-Content -LiteralPath $ownerPath -Encoding UTF8
    if ($service.Status -eq 'Running') { Restart-Service sshd } else { Start-Service sshd }
    Enable-LocalUser -SID $newUser.SID
    Write-Host "`nIP: $($selected.IP)`nBenutzer: $name`nPasswort: $password`nSSH-Befehl: ssh -p $port $name@$($selected.IP)"
    if ($mode -eq '1') { Write-Host "Ablauf: $($params.AccountExpires); bei Neustart erfolgt der Rueckbau frueher." }
} catch {
    Write-Warning "Einrichtung fehlgeschlagen: $($_.Exception.Message)"
    try { Stop-Access } catch { Write-Warning "Rueckbau fehlgeschlagen: $($_.Exception.Message). STOP_HIER erneut als Administrator starten." }
    throw
} finally { $password = $null }

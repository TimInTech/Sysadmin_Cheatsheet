function Get-PrivateSubnet([string]$Address, [int]$PrefixLength) {
    $ip = [System.Net.IPAddress]::Parse($Address)
    if ($ip.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetwork) { throw 'Nur IPv4 wird unterstuetzt.' }
    $bytes = $ip.GetAddressBytes()
    $isPrivate = ($bytes[0] -eq 10 -and $PrefixLength -ge 8) -or
        ($bytes[0] -eq 172 -and $bytes[1] -ge 16 -and $bytes[1] -le 31 -and $PrefixLength -ge 12) -or
        ($bytes[0] -eq 192 -and $bytes[1] -eq 168 -and $PrefixLength -ge 16)
    if (-not $isPrivate -or $PrefixLength -gt 30) { throw 'Das Netzwerk muss ein privates IPv4-LAN mit gueltiger Netzmaske sein.' }
    $network = for ($i=0; $i -lt 4; $i++) {
        $bits = [Math]::Max(0, [Math]::Min(8, $PrefixLength - 8 * $i))
        if ($bits -eq 0) { 0 } else { [int]$bytes[$i] -band [int](256 - [Math]::Pow(2, 8 - $bits)) }
    }
    return (($network -join '.') + '/' + $PrefixLength)
}

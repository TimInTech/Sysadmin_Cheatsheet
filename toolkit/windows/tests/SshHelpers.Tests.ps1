BeforeAll { . (Join-Path (Split-Path $PSScriptRoot -Parent) 'SshHelpers.ps1') }
Describe 'Allowed IPv4 network selection' {
    It 'calculates a private /24 network' { Get-PrivateSubnet '192.168.5.17' 24 | Should -Be '192.168.5.0/24' }
    It 'calculates a non-octet-aligned network' { Get-PrivateSubnet '172.20.18.123' 20 | Should -Be '172.20.16.0/20' }
    It 'rejects public addresses' { { Get-PrivateSubnet '8.8.8.8' 24 } | Should -Throw }
    It 'rejects prefixes that extend outside private ranges' { { Get-PrivateSubnet '192.168.5.17' 8 } | Should -Throw }
}

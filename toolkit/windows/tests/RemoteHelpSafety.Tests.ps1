Describe 'Windows SSH starter release gate' {
    It 'refuses setup before making system changes while safety issues remain' {
        $script = Join-Path (Split-Path $PSScriptRoot -Parent) 'RemoteHelp.ps1'
        { & $script -Action Start } | Should -Throw '*aus Sicherheitsgruenden deaktiviert*'
    }
}

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

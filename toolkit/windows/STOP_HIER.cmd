@echo off
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0RemoteHelp.ps1" -Action Stop
echo.
pause

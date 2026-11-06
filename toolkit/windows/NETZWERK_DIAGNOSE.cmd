@echo off
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0DIAGNOSE.ps1" -Action NETZWERK_DIAGNOSE
echo.
pause

@echo off
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0DIAGNOSE.ps1" -Action SYSTEMINFO
echo.
pause

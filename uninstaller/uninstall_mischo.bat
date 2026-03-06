@echo off
set /p CONFIRM="Are you sure you want to uninstall Mischo? (Y/N): "
if /I "%CONFIRM%" neq "Y" exit /b

taskkill /IM mischo_agent.exe /F >nul 2>&1
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v Mischo /f
rmdir /S /Q "C:\Mischo"
echo Mischo uninstalled.
pause

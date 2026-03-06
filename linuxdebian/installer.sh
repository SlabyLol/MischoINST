@echo off
echo ===============================
echo Installing Mischo Agent
echo ===============================

REM Prüfe Python, installiere Pakete usw. (wie zuvor)
REM ...

REM Create install folder
mkdir C:\Mischo 2>nul
cd C:\Mischo

REM Download agent
powershell -Command "Invoke-WebRequest https://github.com/SlabyLol/MischoINST/raw/main/agent/mischo_agent.py -OutFile mischo_agent.py"

REM Build binary
pyinstaller --onefile mischo_agent.py

REM Start Agent
start dist\mischo_agent.exe

REM Add to startup
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v Mischo /t REG_SZ /d "C:\Mischo\dist\mischo_agent.exe" /f

REM Download Uninstaller
powershell -Command "Invoke-WebRequest https://github.com/SlabyLol/MischoINST/raw/main/uninstaller/uninstall_mischo.bat -OutFile C:\Mischo\uninstall_mischo.bat"

echo Installation complete!
pause

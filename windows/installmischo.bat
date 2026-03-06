@echo off
echo ===============================
echo Installing Mischo Agent
echo ===============================

REM Prüfen, ob python gefunden wird
where python >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Python 3.11+ not found.
    set /p INSTPY="Do you want to install Python from python.org? (Y/N): "
    if /I "%INSTPY%"=="Y" (
        echo Please download and install Python from https://www.python.org/downloads/
        pause
        exit /b
    ) else (
        set /p HASPY="Did you already install Python manually? (Y/N): "
        if /I "%HASPY%"=="Y" (
            echo Make sure Python is added to PATH and restart the installer.
            pause
            exit /b
        ) else (
            echo Python is required. Exiting.
            pause
            exit /b
        )
    )
) else (
    set "PYTHON=python"
)

echo Using %PYTHON% to install packages...

REM pip installieren/updaten
%PYTHON% -m ensurepip
%PYTHON% -m pip install --upgrade pip

REM Packages installieren
%PYTHON% -m pip install pyinstaller mss opencv-python numpy pyautogui websockets pillow

REM Ordner erstellen
mkdir C:\Mischo 2>nul
cd C:\Mischo

REM Agent herunterladen
powershell -Command "Invoke-WebRequest https://github.com/SlabyLol/MischoINST/raw/main/agent/mischo_agent.py -OutFile mischo_agent.py"

REM Binary bauen
pyinstaller --onefile mischo_agent.py

REM Agent starten
start dist\mischo_agent.exe

REM Autostart einrichten
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v Mischo /t REG_SZ /d "C:\Mischo\dist\mischo_agent.exe" /f

echo Installation complete!
pause

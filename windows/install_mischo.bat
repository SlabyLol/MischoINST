@echo off
echo ===============================
echo Installing Mischo Agent
echo ===============================

REM ------------------------
REM 1. Python prüfen
REM ------------------------
py -3 --version >nul 2>&1
if %ERRORLEVEL% == 0 (
    set "PYTHON=py -3"
) else (
    python --version >nul 2>&1
    if %ERRORLEVEL% == 0 (
        set "PYTHON=python"
    ) else (
        echo Python 3 not found.
        set /p INSTPY="Do you want to install Python from python.org? (Y/N): "
        if /I "%INSTPY%"=="Y" (
            echo Please download and install Python from https://www.python.org/downloads/
            pause
            exit /b
        ) else (
            set /p HASPY="Did you already install Python manually? (Y/N): "
            if /I "%HASPY%"=="Y" (
                echo Make sure Python is added to PATH and restart installer.
                pause
                exit /b
            ) else (
                echo Python is required. Exiting.
                pause
                exit /b
            )
        )
    )
)

echo Using %PYTHON% to install packages...

REM ------------------------
REM 2. Pip & Pakete
REM ------------------------
%PYTHON% -m ensurepip
%PYTHON% -m pip install --upgrade pip
%PYTHON% -m pip install pyinstaller pyautogui mss opencv-python numpy websockets pillow cryptography

REM ------------------------
REM 3. Installationsordner
REM ------------------------
set "INSTALL_DIR=C:\Mischo"
mkdir "%INSTALL_DIR%" 2>nul
cd /d "%INSTALL_DIR%"

REM ------------------------
REM 4. Agent herunterladen
REM ------------------------
powershell -Command "Invoke-WebRequest https://github.com/SlabyLol/MischoINST/raw/main/agent/mischo_agent.py -OutFile mischo_agent.py"

REM ------------------------
REM 5. Binary bauen
REM ------------------------
%PYTHON% -m PyInstaller --onefile mischo_agent.py

REM ------------------------
REM 6. Agent starten
REM ------------------------
start dist\mischo_agent.exe

REM ------------------------
REM 7. Autostart einrichten
REM ------------------------
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v Mischo /t REG_SZ /d "%INSTALL_DIR%\dist\mischo_agent.exe" /f

REM ------------------------
REM 8. Uninstaller herunterladen
REM ------------------------
powershell -Command "Invoke-WebRequest https://github.com/SlabyLol/MischoINST/raw/main/uninstaller/uninstall_mischo.bat -OutFile %INSTALL_DIR%\uninstall_mischo.bat"

echo Installation complete!
echo To uninstall Mischo, run %INSTALL_DIR%\uninstall_mischo.bat
pause

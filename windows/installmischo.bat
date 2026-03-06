@echo off
echo ===============================
echo Installing Mischo Agent
echo ===============================

REM Detect Python
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    python3 --version >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo Python 3.11+ not found. Please install it and add to PATH.
        pause
        exit /b
    )
    set PYTHON=python3
) else (
    set PYTHON=python
)

echo Using %PYTHON% to install packages.

REM Ensure pip
%PYTHON% -m ensurepip
%PYTHON% -m pip install --upgrade pip

REM Install required packages
%PYTHON% -m pip install pyinstaller mss opencv-python numpy pyautogui websockets pillow

REM Create folder
mkdir C:\Mischo
cd C:\Mischo

REM Download agent
powershell -Command "Invoke-WebRequest https://github.com/SlabyLol/MischoINST/raw/main/agent/mischo_agent.py -OutFile mischo_agent.py"

REM Build binary
pyinstaller --onefile mischo_agent.py

REM Start Agent
start dist\mischo_agent.exe

REM Add to startup
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v Mischo /t REG_SZ /d "C:\Mischo\dist\mischo_agent.exe" /f

echo Installation complete!
pause

@echo off
echo ===============================
echo Installing Mischo Agent
echo ===============================

REM Create folder
mkdir C:\Mischo
cd C:\Mischo

REM Check Python
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Python 3.11+ is required. Please install it first.
    pause
    exit /b
)

REM Ensure pip
python -m ensurepip

REM Install required packages
python -m pip install --upgrade pip
pip install pyinstaller mss opencv-python numpy pyautogui websockets pillow

REM Download Mischo Agent Python file
powershell -Command "Invoke-WebRequest https://raw.githubusercontent.com/SlabyLol/MischoINST/main/agent/mischo_agent.py -OutFile mischo_agent.py"

REM Build binary
pyinstaller --onefile mischo_agent.py

REM Start Agent
start dist\mischo_agent.exe

REM Add to startup
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v Mischo /t REG_SZ /d "C:\Mischo\dist\mischo_agent.exe" /f

echo Installation complete!
pause

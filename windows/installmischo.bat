@echo off
echo ===============================
echo Installing Mischo Agent
echo ===============================

:CHECKPYTHON
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Python 3.11+ is not found.
    set /p INSTPY="Do you want to install Python? (Y/N): "
    if /I "%INSTPY%"=="Y" (
        echo Please download and install Python from https://www.python.org/downloads/
        pause
        exit /b
    ) else (
        set /p HASPY="Did you already install Python? (Y/N): "
        if /I "%HASPY%"=="Y" (
            goto CHECKPYTHON
        ) else (
            echo Python is required. Exiting.
            pause
            exit /b
        )
    )
) else (
    set PYTHON=python
)

echo Using %PYTHON% to install packages...

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

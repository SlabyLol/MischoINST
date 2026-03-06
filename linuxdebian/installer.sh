#!/bin/bash
echo "==============================="
echo "Installing Mischo Agent"
echo "==============================="

AGENT_DIR="$HOME/.mischo"
mkdir -p "$AGENT_DIR"
cd "$AGENT_DIR"

# Detect python3
if command -v python3 &>/dev/null; then
    PYTHON=python3
else
    echo "Python 3 not found. Installing..."
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv
    PYTHON=python3
fi

# Upgrade pip
$PYTHON -m pip install --upgrade pip

# Install required packages
$PYTHON -m pip install pyinstaller mss opencv-python numpy pyautogui websockets pillow

# Download agent
wget https://github.com/SlabyLol/MischoINST/raw/main/agent/mischo_agent.py -O mischo_agent.py

# Build binary
pyinstaller --onefile mischo_agent.py

# Make executable
chmod +x dist/mischo_agent

# Setup systemd service
mkdir -p ~/.config/systemd/user
cat <<EOF > ~/.config/systemd/user/mischo.service
[Unit]
Description=Mischo Remote Agent

[Service]
ExecStart=$AGENT_DIR/dist/mischo_agent
Restart=always

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable mischo
systemctl --user start mischo

echo "Mischo Agent installed and running!"

#!/bin/bash
echo "==============================="
echo "Installing Mischo Agent"
echo "==============================="

# Folder
AGENT_DIR="$HOME/.mischo"
mkdir -p "$AGENT_DIR"
cd "$AGENT_DIR"

# Install Python and pip if missing
sudo apt update
sudo apt install -y python3-pip python3-venv

# Install required Python packages
pip3 install --upgrade pip
pip3 install pyinstaller mss opencv-python numpy pyautogui websockets pillow

# Download Mischo Agent
wget https://raw.githubusercontent.com/SlabyLol/MischoINST/main/agent/mischo_agent.py -O mischo_agent.py

# Build binary
pyinstaller --onefile mischo_agent.py

# Make executable
chmod +x dist/mischo_agent

# systemd service for autostart
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

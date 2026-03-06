#!/bin/bash
echo "==============================="
echo "Installing Mischo Agent"
echo "==============================="

while ! command -v python3 &>/dev/null; do
    read -p "Python 3 is not installed. Install? (Y/N): " INSTALL
    case "$INSTALL" in
        [Yy]* ) sudo apt update && sudo apt install -y python3 python3-pip python3-venv ;;
        [Nn]* ) read -p "Already installed? (Y/N): " ALREADY
               [[ "$ALREADY" =~ [Yy] ]] || { echo "Python required. Exiting."; exit 1; } ;;
        * ) echo "Please answer Y or N." ;;
    esac
done

PYTHON=python3

$PYTHON -m pip install --upgrade pip
$PYTHON -m pip install pyinstaller mss opencv-python numpy pyautogui websockets pillow

AGENT_DIR="$HOME/.mischo"
mkdir -p "$AGENT_DIR"
cd "$AGENT_DIR"

wget https://github.com/SlabyLol/MischoINST/raw/main/agent/mischo_agent.py -O mischo_agent.py

pyinstaller --onefile mischo_agent.py
chmod +x dist/mischo_agent

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

wget https://github.com/SlabyLol/MischoINST/raw/main/uninstaller/uninstall_mischo.sh -O "$AGENT_DIR/uninstall_mischo.sh"
chmod +x "$AGENT_DIR/uninstall_mischo.sh"

echo "Mischo Agent installed and running!"
echo "To uninstall, run $AGENT_DIR/uninstall_mischo.sh"

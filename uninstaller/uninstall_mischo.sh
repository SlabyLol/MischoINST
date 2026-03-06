#!/bin/bash
read -p "Are you sure you want to uninstall Mischo? (Y/N): " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || exit 1

systemctl --user stop mischo 2>/dev/null
systemctl --user disable mischo 2>/dev/null
rm -f ~/.config/systemd/user/mischo.service
systemctl --user daemon-reload
rm -rf ~/.mischo
echo "Mischo uninstalled."

#!/bin/bash

# Setup EasyTether auto-run environment with notifications

set -e

EASYTETHER_DIR="$HOME/easytether"
BIN_DIR="/usr/local/bin"
AUTOSTART_DIR="$HOME/.config/autostart"

echo "Creating easytether directory if missing..."
mkdir -p "$EASYTETHER_DIR"
mkdir -p "$AUTOSTART_DIR"

echo "Creating easytether loop runner script..."
cat > "$BIN_DIR/easytether" << 'EOF'
#!/bin/bash
while true; do
    bash $HOME/easytether/easytether.sh
    echo "[EasyTether] Restarting in 5s..."
    sleep 5
done
EOF
chmod +x "$BIN_DIR/easytether"

echo "Creating easytether-start script..."
cat > "$BIN_DIR/easytether-start" << 'EOF'
#!/bin/bash
nohup easytether > /dev/null 2>&1 &
echo $! > $HOME/.easytether.pid
notify-send -u normal "EasyTether" "Started and running in background."
echo "EasyTether started."
EOF
chmod +x "$BIN_DIR/easytether-start"

echo "Creating killeasytether script..."
cat > "$BIN_DIR/killeasytether" << 'EOF'
#!/bin/bash
if [ -f "$HOME/.easytether.pid" ]; then
    kill $(cat "$HOME/.easytether.pid") && \
    notify-send -u normal "EasyTether" "Stopped." && \
    echo "EasyTether stopped."
    rm "$HOME/.easytether.pid"
else
    notify-send -u normal "EasyTether" "Not running."
    echo "No EasyTether PID file found."
fi
EOF
chmod +x "$BIN_DIR/killeasytether"

echo "Creating autostart desktop entry..."
cat > "$AUTOSTART_DIR/easytether.desktop" << EOF
[Desktop Entry]
Type=Application
Exec=$BIN_DIR/easytether-start
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=EasyTether
EOF

echo "Installing notify-send if missing..."
if ! command -v notify-send &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y libnotify-bin
fi

echo "Setup complete!
- Run 'easytether-start' to start EasyTether in background.
- Run 'killeasytether' to stop it.
- It will auto-start on login."


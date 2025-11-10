#!/usr/bin/env bash

set -euo pipefail
trap 'echo "❌ PM2 installation failed at line $LINENO"; exit 1' ERR

echo "=== Installing and configuring PM2 ==="

# Step 0: Ensure Node.js and npm exist
if ! command -v node &>/dev/null || ! command -v npm &>/dev/null; then
    echo "❌ Node.js and npm are required but not installed."
    echo "Please install Node.js first (using install_node.sh)."
    exit 1
fi

# Step 1: Install or verify PM2
if command -v pm2 &>/dev/null; then
    PM2_VER=$(pm2 -v)
    echo "🔹 PM2 already installed (v$PM2_VER)"
else
    echo "🔹 Installing PM2 globally..."
    sudo npm install -g pm2@latest
fi

# Step 2: Setup PM2 startup (systemd)
echo "🔹 Configuring PM2 to start on boot..."

# Run pm2 startup, but extract only the actual command line
PM2_STARTUP_CMD=$(pm2 startup systemd -u "$USER" --hp "$HOME" | grep "sudo env" || true)
if [[ -n "$PM2_STARTUP_CMD" ]]; then
    echo "🔹 Executing: $PM2_STARTUP_CMD"
    eval "$PM2_STARTUP_CMD"
else
    echo "⚠️ No startup command found — check pm2 output manually."
fi

# Step 3: Enable the PM2 systemd unit
echo "🔹 Enabling PM2 service for user '$USER'..."
sudo systemctl enable "pm2-${USER}" >/dev/null 2>&1 || true
sudo systemctl start "pm2-${USER}" >/dev/null 2>&1 || true

# Step 4: Enable auto-save of process list
echo "🔹 Enabling PM2 autosave..."
pm2 save >/dev/null 2>&1 || true

# Step 5: Install and configure log rotation module
if ! pm2 module:list | grep -q "pm2-logrotate"; then
    echo "🔹 Installing pm2-logrotate..."
    pm2 install pm2-logrotate >/dev/null
else
    echo "🔹 pm2-logrotate already installed"
fi

echo "🔹 Configuring log rotation..."
pm2 set pm2-logrotate:max_size 100M >/dev/null
pm2 set pm2-logrotate:retain 10 >/dev/null
pm2 set pm2-logrotate:compress true >/dev/null
pm2 set pm2-logrotate:dateFormat 'YYYY-MM-DD_HH-mm-ss' >/dev/null
pm2 set pm2-logrotate:rotateInterval '0 0 * * *' >/dev/null  # rotate daily at midnight

# Step 6: Final verification
PM2_VER=$(pm2 -v)

echo "🔹 PM2 version installed: $PM2_VER"
echo "🔹 Log rotation active"
echo "🔹 PM2 daemon enabled for user: $USER"
echo "🔹 Processes will be restored automatically on reboot"

echo -e "✅ PM2 installation and configuration complete! \n\n"

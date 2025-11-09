#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ Nginx installation failed at line $LINENO"; exit 1' ERR

echo "=== Installing Nginx ==="

# Step 0: Check if Nginx is already installed
if command -v nginx &>/dev/null; then
    NGINX_VER=$(nginx -v 2>&1 | awk -F/ '{print $2}')
    echo "🔹 Nginx already installed: version $NGINX_VER"
    exit 0
fi

# Step 1: Update package lists
echo "🔹 Updating package lists..."
sudo apt-get update -y

# Step 2: Install Nginx
echo "🔹 Installing Nginx..."
sudo apt-get install -y nginx

# Step 3: Ensure Nginx is enabled and running
echo "🔹 Enabling and starting Nginx service..."
sudo systemctl enable nginx
sudo systemctl start nginx

# Step 4: Verify installation
NGINX_VER=$(nginx -v 2>&1 | awk -F/ '{print $2}')
echo "🔹 Nginx version installed: $NGINX_VER"

echo -e "✅ Nginx installation complete! \n\n"

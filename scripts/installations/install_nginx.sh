#!/usr/bin/env bash

set -euo pipefail
trap 'echo "❌ Nginx installation failed at line $LINENO"; exit 1' ERR

echo "=== Installing Nginx & Certbot ==="

#
# --- NGINX ---
#
if command -v nginx &>/dev/null; then
    NGINX_VER=$(nginx -v 2>&1 | awk -F/ '{print $2}')
    echo "🔹 Nginx already installed: version $NGINX_VER"
else
    echo "🔹 Installing Nginx..."

    sudo apt-get update -y
    sudo apt-get install -y nginx

    sudo systemctl enable nginx
    sudo systemctl start nginx

    NGINX_VER=$(nginx -v 2>&1 | awk -F/ '{print $2}')
fi

#
# --- CERTBOT ---
#
if command -v certbot &>/dev/null; then
    echo "🔹 Certbot already installed"
else
    echo "🔹 Installing Certbot..."
    sudo apt-get update -y
    sudo apt-get install -y certbot
fi

#
# --- python3-certbot-nginx ---
#
if dpkg -l | grep -q "^ii\s\+python3-certbot-nginx\s"; then
    echo "🔹 python3-certbot-nginx already installed"
else
    echo "🔹 Installing python3-certbot-nginx..."
    sudo apt-get update -y
    sudo apt-get install -y python3-certbot-nginx
fi

echo "🔹 Nginx version installed: $NGINX_VER"

echo -e "✅ Nginx and certbot installation complete! \n\n"

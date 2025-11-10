#!/usr/bin/env bash

set -euo pipefail
trap 'echo "❌ UFW configuration failed at line $LINENO"; exit 1' ERR

echo "=== UFW FIREWALL CONFIGURATION ==="

# --- Check if UFW is installed ---
if ! command -v ufw &>/dev/null; then
    echo "⚠️ UFW is not installed. Installing..."
    sudo apt-get update -y
    sudo apt-get install ufw -y
    echo -e "UFW installed \n"
fi

# --- Preflight check: ensure SSH is allowed ---
if ! sudo ufw status numbered | grep -q "22/tcp"; then
    echo "⚠️ SSH (port 22) is not currently allowed in UFW. This script will add it, but ensure you have console access in case of issues."
fi

# --- Reset UFW to default ---
echo "⚙️ Resetting UFW to default configuration..."
sudo ufw --force reset
echo -e "UFW reset complete \n"

# --- Set default policies ---
echo "⚙️  Setting default policies..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
echo -e "Default policies set (deny incoming, allow outgoing) \n"

# --- Allow required ports ---
echo "⚙️ Allowing essential ports..."
sudo ufw allow 22/tcp  # SSH
sudo ufw allow 80/tcp  # HTTP
sudo ufw allow 443/tcp # HTTPS
echo -e "Ports 22, 80, 443 allowed \n"

# --- Enable UFW ---
echo "Enabling UFW firewall..."
sudo ufw --force enable
echo -e "UFW is now active \n"

# --- Show status ---
echo "📊 Current UFW status:"
sudo ufw status verbose

echo -e "✅ Firewall setup complete! \n\n"

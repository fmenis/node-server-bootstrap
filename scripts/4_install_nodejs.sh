#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ Node.js installation failed at line $LINENO"; exit 1' ERR

echo "=== Installing Node.js LTS via NodeSource PPA ==="

# Step 0: Check if Node.js is already installed
if command -v node &>/dev/null; then
    NODE_VER=$(node -v)
    echo "🔹 Node.js already installed: $NODE_VER"
else
    # Step 1: Add NodeSource LTS repository
    echo "🔹 Adding NodeSource Node.js LTS repository..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

    # Step 2: Install Node.js
    echo "🔹 Installing Node.js..."
    sudo apt-get install -y nodejs
fi

# Step 3: Print Node.js and npm versions
echo "🔹 Node.js version: $(node -v)"
echo "🔹 npm version: $(npm -v)"

echo -e "✅ Node.js LTS installation complete! \n\n"

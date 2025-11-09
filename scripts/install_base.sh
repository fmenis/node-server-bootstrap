#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ Base package installation failed at line $LINENO"; exit 1' ERR

echo "=== Installing base packages ==="

# List of essential packages
PACKAGES=(
    curl                  # For downloading scripts
    wget                  # Optional downloads
    git                   # Clone repositories
    build-essential       # gcc, g++, make for native modules
    unzip                 # For zip files
    ca-certificates       # SSL certs
    gnupg                 # For adding PPAs
    lsb-release           # Detect distro release
    software-properties-common  # add-apt-repository support
    net-tools
    htop
)

# Step 1: Update package lists
echo "🔄 Updating package lists..."
sudo apt-get update -y

# Step 2: Install each package defensively
for pkg in "${PACKAGES[@]}"; do
    if dpkg -s "$pkg" &>/dev/null; then
        echo "🔹 Package '$pkg' is already installed"
    else
        echo "🔹 Installing '$pkg'..."
        sudo apt-get install -y "$pkg"
    fi
done

# Step 3: Clean up
echo "🧹 Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get autoclean -y

echo "✅ Base packages installation complete"

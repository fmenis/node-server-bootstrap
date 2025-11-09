#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ Provisioning failed at line $LINENO"; exit 1' ERR

echo "=== Updating and upgrading system packages ==="

# Update package lists safely
echo "🔄 Checking for package updates..."
if sudo apt-get update -y; then
    echo "Package lists updated"
else
    echo "⚠️ Failed to update package lists, exiting"
    exit 1
fi

# Upgrade installed packages safely
echo "🔄 Upgrading installed packages..."
if sudo apt-get upgrade -y; then
    echo "Packages upgraded"
else
    echo "⚠️ Failed to upgrade packages, exiting"
    exit 1
fi

# Clean up unnecessary packages
echo "🧹 Cleaning up unnecessary packages..."
sudo apt-get autoremove -y
sudo apt-get autoclean -y

echo -e "✅ System update and cleanup complete! \n\n"
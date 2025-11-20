#!/usr/bin/env bash

set -euo pipefail
trap 'echo "❌ Redis installation failed at line $LINENO"; exit 1' ERR

echo "=== Installing Redis ==="

#
# --- Check if Redis is already installed ---
#
if command -v redis-server &>/dev/null; then
    REDIS_VER=$(redis-server --version | awk '{print $3}' | cut -d'=' -f2)
    echo "🔹 Redis already installed: version $REDIS_VER"
    exit 0
fi


#
# --- Install Redis ---
#
echo "🔹 Updating package lists..."
sudo apt-get update -y

echo "🔹 Installing Redis..."
sudo apt-get install -y redis-server


#
# --- Enable + start Redis service ---
#
echo "🔹 Enabling and starting Redis service..."
sudo systemctl enable redis-server
sudo systemctl start redis-server


#
# --- Verify installation ---
#
if systemctl is-active --quiet redis-server; then
    REDIS_VER=$(redis-server --version | awk '{print $3}' | cut -d'=' -f2)
    echo "🔹 Redis version installed: $REDIS_VER"
else
    echo "❌ Redis service failed to start"
    exit 1
fi


echo -e "✅ Redis installation complete! \n\n"

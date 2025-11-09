#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ Provisioning failed at line $LINENO"; exit 1' ERR

# Base directory of the project
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts"

echo "=============================================="
echo "🛠️  Starting full server provisioning"
echo "=============================================="

# Step 1: Update and upgrade system
echo "✅ Running update_system.sh"
bash "$BASE_DIR/update_system.sh"

# Step 2: Install base packages (curl, git, etc.)
echo "✅ Running install_base.sh"
bash "$BASE_DIR/install_base.sh"

# Step 3: Install Node.js LTS
echo "✅ Running install_node.sh"
bash "$BASE_DIR/install_node.sh"

# Step 4: Install PostgreSQL LTS
echo "✅ Running install_postgres.sh"
bash "$BASE_DIR/install_postgres.sh"

# Step 5: Install Nginx
echo "✅ Running install_nginx.sh"
bash "$BASE_DIR/install_nginx.sh"

echo "=============================================="
echo "🎉 Full provisioning completed successfully!"
echo "=============================================="

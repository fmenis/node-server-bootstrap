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

echo "=============================================="
echo "🎉 Full provisioning completed successfully!"
echo "=============================================="

#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ Provisioning failed at line $LINENO"; exit 1' ERR

# Base directory of the project
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts"

# Global pause duration in seconds between scripts
PAUSE_SECONDS=2

echo "=============================================="
echo "🛠️  Starting full server provisioning"
echo -e "============================================== \n\n"

run_step() {
    local step_name="$1"
    local script_path="$2"
    
    echo "🔄 Running $step_name"
    bash "$script_path"
    # echo "⏸️  Pausing for $PAUSE_SECONDS seconds..."
    sleep "$PAUSE_SECONDS"
}

# Step 1: Update and upgrade system
run_step "update_system.sh" "$BASE_DIR/1_update_system.sh"

# Step 2: Install base packages (curl, git, etc.)
run_step "install_base.sh" "$BASE_DIR/2_install_base.sh"

# Step 3: Create project directories
run_step "install_base.sh" "$BASE_DIR/3_create_project_dirs.sh"

# Step 4: Install Node.js LTS
run_step "install_node.sh" "$BASE_DIR/4_install_nodejs.sh"

# Step 5: Install and configure PM2
run_step "install_pm2.sh" "$BASE_DIR/5_install_pm2.sh"

# Step 6: Install PostgreSQL LTS
run_step "install_postgres.sh" "$BASE_DIR/6_install_postgres.sh"

# Step 7: Install Nginx
run_step "install_nginx.sh" "$BASE_DIR/7_install_nginx.sh"

echo -e "\n\n"

echo "=============================================="
echo "🎉 Full provisioning completed successfully!"
echo "=============================================="
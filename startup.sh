#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ Provisioning failed at line $LINENO"; exit 1' ERR

# Base directory of the project
INSTALLATION_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/installations"
CONFIGURATION_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/configurations"

# Global pause duration in seconds between scripts
PAUSE_SECONDS=2

echo -e "\n"
echo "=============================================="
echo "🛠️  Starting full server provisioning"
echo -e "============================================== \n\n"

run_step() {
    local step_name="$1"
    local script_path="$2"
    
    echo "🔄 Running $step_name"
    bash "$script_path"

    sleep "$PAUSE_SECONDS"
}

### ------------------------ INSTALLATIONS ------------------------

# Step 1: Update and upgrade system
run_step "update_system.sh" "$INSTALLATION_BASE_DIR/update_system.sh"

# Step 2: Install base packages (curl, git, etc.)
run_step "install_base.sh" "$INSTALLATION_BASE_DIR/install_base.sh"

# Step 3: Create ssh keys
run_step "create_ssh_keys.sh" "$INSTALLATION_BASE_DIR/create_ssh_keys.sh"

# Step 4: Create project directories
run_step "create_project_dirs.sh" "$INSTALLATION_BASE_DIR/create_project_dirs.sh"

# Step 5: Install Node.js LTS
run_step "install_node.sh" "$INSTALLATION_BASE_DIR/install_nodejs.sh"

# Step 6: Install and configure PM2
run_step "install_pm2.sh" "$INSTALLATION_BASE_DIR/install_pm2.sh"

# Step 7: Install PostgreSQL LTS
run_step "install_postgres.sh" "$INSTALLATION_BASE_DIR/install_postgres.sh"

# Step 8: Install Nginx
run_step "install_nginx.sh" "$INSTALLATION_BASE_DIR/install_nginx.sh"

### ------------------------ CONFIGURATIONS ------------------------

# Step 9: Create database and configure role
run_step "create_db.sh" "$CONFIGURATION_BASE_DIR/create_db.sh"

# Step 10: Create reverse proxy
run_step "nginx_server_blocks.sh" "$CONFIGURATION_BASE_DIR/nginx_server_blocks.sh"

# Step 11: Configure UFW
run_step "enable_ufw.sh" "$CONFIGURATION_BASE_DIR/enable_ufw.sh"

echo -e "\n"

echo "=============================================="
echo "🎉 Full provisioning completed successfully!"
echo "=============================================="

echo -e "\n\n"

#!/usr/bin/env bash

set -euo pipefail
trap 'echo "❌ Directory creation failed at line $LINENO"; exit 1' ERR

echo "=== Creating project directories with proper permissions ==="

# Prompt user for project names
read -rp "Enter backend project name (default: my_backend_app): " BACKEND_PROJECT_NAME
BACKEND_PROJECT_NAME=${BACKEND_PROJECT_NAME:-my_backend_app}


# User that will own the files (typically the sudoer)
USER_NAME="${SUDO_USER:-$USER}"
WEB_GROUP="www-data"

# Directories
BACKEND_DIR="/opt/$BACKEND_PROJECT_NAME"
BACKEND_LOG_DIR="/var/logs/$BACKEND_PROJECT_NAME"

# Function to create directory if missing and set ownership & permissions
create_dir() {
    local dir_path="$1"
    local owner="$2"
    local group="$3"
    local mode="$4"

    if [ ! -d "$dir_path" ]; then
        echo "🔹 Creating $dir_path"
        sudo mkdir -p "$dir_path"
    else
        echo "🔹 Directory $dir_path already exists"
    fi

    echo "🔹 Setting owner:$owner, group:$group, permissions:$mode"
    sudo chown "$owner:$group" "$dir_path"
    sudo chmod "$mode" "$dir_path"
}

# Backend directory (owner: sudo user, group: www-data)
create_dir "$BACKEND_DIR" "$USER_NAME" "$WEB_GROUP" 775

# Backend logs directory (owner: sudo user, group: www-data)
create_dir "$BACKEND_LOG_DIR" "$USER_NAME" "$WEB_GROUP" 775

echo "🔹 Backend: $BACKEND_DIR"
echo "🔹 Backend logs: $BACKEND_LOG_DIR"

echo -e "✅ Project directories created successfully with web group access! \n\n"
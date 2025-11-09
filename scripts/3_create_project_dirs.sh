#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ Directory creation failed at line $LINENO"; exit 1' ERR

echo "=== Creating project directories ==="

# === CONFIGURATION ===
BACKEND_PROJECT_NAME="my_backend_app"
CLIENT_PROJECT_NAME="my_client_app"

# User that will own the files (typically the sudoer)
USER_NAME="${SUDO_USER:-$USER}"

# Directories
BACKEND_DIR="/opt/$BACKEND_PROJECT_NAME"
CLIENT_DIR="/var/www/$CLIENT_PROJECT_NAME"
BACKEND_LOG_DIR="/var/logs/$BACKEND_PROJECT_NAME"

# Function to create directory if missing
create_dir() {
    local dir_path="$1"
    local owner="$2"
    local mode="$3"

    if [ ! -d "$dir_path" ]; then
        echo "🔹 Creating $dir_path"
        sudo mkdir -p "$dir_path"
    else
        echo "🔹 Directory $dir_path already exists"
    fi

    echo "🔹 Setting owner to $owner and permissions to $mode"
    sudo chown "$owner":"$owner" "$dir_path"
    sudo chmod "$mode" "$dir_path"
}

# Create backend directory
create_dir "$BACKEND_DIR" "$USER_NAME" 755

# Create backend logs directory
create_dir "$BACKEND_LOG_DIR" "$USER_NAME" 755

# Create client directory
create_dir "$CLIENT_DIR" "$USER_NAME" 755

echo "✅ Project directories created successfully"
echo "🔹 Backend: $BACKEND_DIR"
echo "🔹 Backend logs: $BACKEND_LOG_DIR"
echo "🔹 Client:  $CLIENT_DIR"
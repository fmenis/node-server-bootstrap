#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ failed at line $LINENO"; exit 1' ERR

echo "=== Fastify VPS deploy script (SSH) ==="

# Prompt for SSH GitHub repository URL, target directory and branch
read -rp "Enter the GitHub SSH repository URL (e.g., git@github.com:user/repo.git): " REPO_URL
read -rp "Enter the full path to the target directory on the VPS: " TARGET_DIR
read -rp "Enter branch or tag to clone (default: main): " BRANCH

BRANCH=${BRANCH:-main}

# Ensure target directory exists
mkdir -p "$TARGET_DIR"

# Clone or update repository
if [ -d "$TARGET_DIR/.git" ]; then
  echo "Repository already exists in $TARGET_DIR, pulling latest changes..."
  git -C "$TARGET_DIR" fetch --all --tags
  git -C "$TARGET_DIR" reset --hard "origin/$BRANCH"
else
  echo "Cloning repository..."
  git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR"
fi

#  Move into project directory
cd "$TARGET_DIR"

# Create .env file by prompting user
echo "Creating .env file..."
ENV_FILE="$TARGET_DIR/.env"

# If .env already exists, avoid overwriting
if [ -f "$ENV_FILE" ]; then
  echo "❌ ERROR: .env already exists at $ENV_FILE"
  echo "Refusing to overwrite. Remove it manually if you want to recreate it."
  exit 1
fi

# Prompt values
read -rp "Enter NODE_ENV (default: production): " NODE_ENV
NODE_ENV=${NODE_ENV:-production}

read -rp "Enter APP_ENV (default: development): " APP_ENV
APP_ENV=${APP_ENV:-development}

read -rp "Enter APP_NAME (default: dev-api): " APP_NAME
APP_NAME=${APP_NAME:-dev-api}

read -rp "Enter SERVER_ADDRESS (default: localhost): " SERVER_ADDRESS
SERVER_ADDRESS=${SERVER_ADDRESS:-localhost}

read -rp "Enter SERVER_PORT (default: 3000): " SERVER_PORT
SERVER_PORT=${SERVER_PORT:-3000}

read -rp "Enter LOG_LEVEL (default: debug): " LOG_LEVEL
LOG_LEVEL=${LOG_LEVEL:-debug}

read -rp "Enter PG_HOST (default: localhost): " PG_HOST
PG_HOST=${PG_HOST:-localhost}

read -rp "Enter PG_PORT (default: 6432): " PG_PORT
PG_PORT=${PG_PORT:-5432}

read -rp "Enter PG_DB (default: test): " PG_DB
PG_DB=${PG_DB:-test}

read -rp "Enter PG_USER (default: dev): " PG_USER
PG_USER=${PG_USER:-dev}

read -rsp "Enter PG_PW: " PG_PW
echo

# Write .env
cat <<EOF > "$ENV_FILE"
NODE_ENV=$NODE_ENV
APP_ENV=$APP_ENV
APP_NAME=$APP_NAME

SERVER_ADDRESS=$SERVER_ADDRESS
SERVER_PORT=$SERVER_PORT

LOG_LEVEL=$LOG_LEVEL

PG_HOST=$PG_HOST
PG_PORT=$PG_PORT
PG_DB=$PG_DB
PG_USER=$PG_USER
PG_PW=$PG_PW
EOF

chmod 600 "$ENV_FILE"
echo "✅ .env file created at $ENV_FILE"

# Install dependencies
echo "Installing dependencies..."
npm ci

# Build TypeScript project
echo "Building project..."
npm run build

# Build TypeScript project
echo "Apply migrations..."
npm run applyMigrations

echo "✅ Repository initialized successfully."

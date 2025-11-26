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

read -rp "Enter API_DOMAIN (default: api.filippomenis.it): " API_DOMAIN
API_DOMAIN=${API_DOMAIN:-api.filippomenis.it}

read -rp "Enter SERVER_ADDRESS (default: localhost): " SERVER_ADDRESS
SERVER_ADDRESS=${SERVER_ADDRESS:-localhost}

read -rp "Enter SERVER_PORT (default: 3000): " SERVER_PORT
SERVER_PORT=${SERVER_PORT:-3000}

read -rp "Enter LOG_LEVEL (default: debug): " LOG_LEVEL
LOG_LEVEL=${LOG_LEVEL:-debug}

read -rp "Enter DATABASE_URL: " DATABASE_URL

read -rp "Enter REDIS_HOST (default: localhost): " REDIS_HOST
REDIS_HOST=${REDIS_HOST:-localhost}

read -rp "Enter REDIS_PORT (default: 6379): " REDIS_PORT
REDIS_PORT=${REDIS_PORT:-6379}

read -rp "Enter SENTRY_ENABLED (default: false): " SENTRY_ENABLED
SENTRY_ENABLED=${SENTRY_ENABLED:-false}

read -rp "Enter SENTRY_DSN: " SENTRY_DSN

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

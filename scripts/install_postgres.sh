#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ PostgreSQL installation failed at line $LINENO"; exit 1' ERR

echo "=== Installing PostgreSQL LTS via manual Apt repository setup ==="

# Step 0: Check if PostgreSQL is already installed
if command -v psql &>/dev/null; then
    PG_VER=$(psql -V | awk '{print $3}')
    echo "🔹 PostgreSQL already installed: $PG_VER"
    exit 0
fi

# Step 2: Import PostgreSQL signing key
PG_KEYRING=/usr/share/keyrings/postgresql-archive-keyring.gpg
if [ ! -f "$PG_KEYRING" ]; then
    echo "🔹 Importing PostgreSQL signing key..."
    wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o "$PG_KEYRING"
else
    echo "🔹 PostgreSQL signing key already exists"
fi

# Step 3: Add PostgreSQL Apt repository
PG_REPO_FILE=/etc/apt/sources.list.d/pgdg.list
if [ ! -f "$PG_REPO_FILE" ]; then
    echo "🔹 Adding PostgreSQL Apt repository..."
    echo "deb [signed-by=$PG_KEYRING] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
        | sudo tee "$PG_REPO_FILE" > /dev/null
else
    echo "🔹 PostgreSQL Apt repository already exists"
fi

# Step 4: Update package lists
sudo apt-get update -y

# Step 5: Install PostgreSQL (latest LTS, e.g., version 18)
PG_VERSION=18
echo "🔹 Installing PostgreSQL $PG_VERSION..."
sudo apt-get install -y "postgresql-$PG_VERSION" "postgresql-contrib-$PG_VERSION"

# Step 6: Print installed version
PG_VER=$(psql -V | awk '{print $3}')
echo "🔹 PostgreSQL version installed: $PG_VER"

echo "✅ PostgreSQL installation complete"

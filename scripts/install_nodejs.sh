#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ Node.js installation failed at line $LINENO"; exit 1' ERR

echo "=== Installing NVM & Node.js LTS ==="

NVM_DIR="${HOME}/.nvm"

# Step 1: Install NVM if not already installed
if [ ! -d "$NVM_DIR" ]; then
    echo "🔹 NVM not found, installing..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
else
    echo "🔹 NVM already installed"
fi

# Step 2: Run NVM commands in a login shell to avoid PATTERN errors
echo "🔹 Installing latest Node.js LTS and setting default..."

bash -l -c '
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Install latest LTS Node.js if not installed
NODE_LTS_VERSION=$(nvm ls-remote --lts | tail -1 | awk "{print \$1}")
if nvm ls "$NODE_LTS_VERSION" >/dev/null 2>&1; then
    echo "🔹 Node.js $NODE_LTS_VERSION already installed"
else
    echo "🔹 Installing Node.js $NODE_LTS_VERSION"
    nvm install --lts
fi

# Set default LTS
nvm alias default "$NODE_LTS_VERSION"
nvm use default

# Print Node and npm versions
echo "🔹 Node.js version: $(node -v)"
echo "🔹 npm version: $(npm -v)"
'

echo "✅ Node.js LTS installation complete"

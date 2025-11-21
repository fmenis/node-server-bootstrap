#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ failed at line $LINENO"; exit 1' ERR

echo "=== Fastify + systemd setup script ==="

# Prompt for project directory
read -rp "Enter the full path to your Fastify project: " PROJECT_DIR

if [ ! -d "$PROJECT_DIR" ]; then
  echo "❌ Directory '$PROJECT_DIR' does not exist."
  exit 1
fi

# Prompt for Node start command (default)
DEFAULT_NODE_CMD="node -r dotenv/config dist/server.js"
read -rp "Enter the Node.js start command [$DEFAULT_NODE_CMD]: " NODE_CMD
NODE_CMD="${NODE_CMD:-$DEFAULT_NODE_CMD}"

# Prompt for system user (default = ubuntu)
DEFAULT_SYSTEM_USER="ubuntu"
read -rp "Enter the system user to run Fastify [$DEFAULT_SYSTEM_USER]: " SYSTEM_USER
SYSTEM_USER="${SYSTEM_USER:-$DEFAULT_SYSTEM_USER}"

if ! id "$SYSTEM_USER" &>/dev/null; then
  echo "❌ User '$SYSTEM_USER' does not exist."
  exit 1
fi

# Create run script
RUN_SCRIPT="/usr/local/bin/run-fastify.sh"

sudo tee "$RUN_SCRIPT" > /dev/null <<EOF
#!/usr/bin/env bash
set -euo pipefail

cd "$PROJECT_DIR"

# Load environment variables from .env
if [ -f .env ]; then
  export \$(grep -v '^#' .env | xargs)
fi

# Start the server
exec $NODE_CMD
EOF

sudo chmod +x "$RUN_SCRIPT"
echo "✅ Created run script at $RUN_SCRIPT"

# Create systemd unit file with requested structure
SERVICE_FILE="/etc/systemd/system/fastify-app.service"

sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Fastify Node.js API
After=network.target

[Service]
Type=simple

User=$SYSTEM_USER
Group=$SYSTEM_USER

WorkingDirectory=$PROJECT_DIR

ExecStart=$RUN_SCRIPT

Restart=always
RestartSec=5

LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable the service
sudo systemctl daemon-reload
sudo systemctl enable fastify-app
sudo systemctl start fastify-app

echo "Check logs with: sudo journalctl -u fastify-app -f"
echo "✅ Fastify service started and enabled at boot"

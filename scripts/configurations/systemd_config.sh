#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ failed at line $LINENO"; exit 1' ERR

echo "=== Fastify + systemd setup script ==="

##TODO add clustering feature

# 1️⃣ Prompt for project directory
read -rp "Enter the full path to your Fastify project: " PROJECT_DIR

if [ ! -d "$PROJECT_DIR" ]; then
  echo "❌ Directory '$PROJECT_DIR' does not exist."
  exit 1
fi

# 2️⃣ Prompt for Node start command
read -rp "Enter the Node.js start command (e.g., node -r dotenv/config dist/server.js): " NODE_CMD

# 3️⃣ Prompt for system user to run the service
read -rp "Enter the system user to run Fastify (e.g., ubuntu): " SYSTEM_USER

if ! id "$SYSTEM_USER" &>/dev/null; then
  echo "❌ User '$SYSTEM_USER' does not exist."
  exit 1
fi

# 4️⃣ Create run script
RUN_SCRIPT="/usr/local/bin/run-fastify.sh"
sudo tee "$RUN_SCRIPT" > /dev/null <<EOF
#!/usr/bin/env bash
set -euo pipefail

# Move into project directory
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

# 5️⃣ Create systemd unit file with requested structure
SERVICE_FILE="/etc/systemd/system/fastify-app.service"
sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Fastify Node.js API
After=network.target

[Service]
Type=simple
# User and group to run the app as (preferably non-root)
User=$SYSTEM_USER
Group=$SYSTEM_USER

# Working directory (project root)
WorkingDirectory=$PROJECT_DIR

# Command to start your app
ExecStart=$RUN_SCRIPT

# Restart automatically on failure
Restart=always
RestartSec=5

# Optional: limits
LimitNOFILE=65535

# Environment file (optional if your run.sh already loads .env)
# EnvironmentFile=$PROJECT_DIR/.env

[Install]
WantedBy=multi-user.target
EOF

# 6️⃣ Reload systemd and enable the service
sudo systemctl daemon-reload
sudo systemctl enable fastify-app
sudo systemctl start fastify-app

echo "✅ Fastify service started and enabled at boot"
echo "Check logs with: sudo journalctl -u fastify-app -f"
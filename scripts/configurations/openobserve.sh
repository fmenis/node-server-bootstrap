#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ Provisioning failed at line $LINENO"; exit 1' ERR

echo "=== OpenObserve (O2) VPS Setup ==="

# --- 1) Prompt for root user email and password ---
read -rp "Enter OpenObserve root user email: " O2_ROOT_EMAIL
read -rsp "Enter OpenObserve root user password: " O2_ROOT_PASSWORD
echo

# --- 2) Prompt for domain name for HTTPS access ---
read -rp "Enter domain name for OpenObserve UI (e.g. logs.example.com): " DOMAIN

# --- 3) Prompt for app user email and password ---
read -rp "Enter OpenObserve app user email: " O2_APP_EMAIL
read -rsp "Enter OpenObserve app user password: " O2_APP_PASSWORD
echo

# --- 4) Variables ---
O2_VERSION="v0.16.3"
O2_INSTALL_DIR="/opt/openobserve"
O2_DATA_DIR="/var/lib/openobserve"

# --- 5) Create directories ---
sudo mkdir -p "$O2_INSTALL_DIR" "$O2_DATA_DIR"
sudo chown -R root:root "$O2_INSTALL_DIR" "$O2_DATA_DIR"

# --- 6) Download and install OpenObserve binary ---
curl -L https://raw.githubusercontent.com/openobserve/openobserve/main/downloadO2.sh | sh -s o2-enterprise "$O2_VERSION"

# --- 7) Systemd service for OpenObserve ---
sudo tee /etc/systemd/system/openobserve.service > /dev/null <<EOF
[Unit]
Description=OpenObserve Log Storage + UI
After=network.target

[Service]
Type=simple
WorkingDirectory=$O2_INSTALL_DIR
ExecStart=$O2_INSTALL_DIR/openobserve
Restart=always
RestartSec=3
User=root

Environment=ZO_LOCAL_MODE=true
Environment=ZO_HTTP_ENABLE=true
Environment=ZO_HTTP_PORT=5080
Environment=ZO_DATA_DIR=$O2_DATA_DIR
Environment=ZO_ROOT_USER_EMAIL=$O2_ROOT_EMAIL
Environment=ZO_ROOT_USER_PASSWORD=$O2_ROOT_PASSWORD
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now openobserve

# --- 8) Wait a few seconds for OpenObserve to initialize ---
echo "⏳ Waiting 10s for OpenObserve to initialize..."
sleep 10

# --- 9) Create dedicated app user ---
echo "Creating OpenObserve app user..."
"$O2_INSTALL_DIR/openobserve" users add \
  --email "$O2_APP_EMAIL" \
  --password "$O2_APP_PASSWORD" \
  --role "user" \
  --local-mode true

# --- 10) Configure Nginx server block ---
sudo tee /etc/nginx/sites-available/openobserve.conf > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:5080/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/openobserve.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# --- 11) Enable HTTPS with Let's Encrypt ---
sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "$O2_ROOT_EMAIL"

echo "UI available at: https://$DOMAIN"
echo "Root user: $O2_ROOT_EMAIL"
echo "App user: $O2_APP_EMAIL"

echo "✅ OpenObserve setup complete!"
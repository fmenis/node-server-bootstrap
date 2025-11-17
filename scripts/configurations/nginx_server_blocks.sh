#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ Proxy configuration failed at line $LINENO"; exit 1' ERR

echo -e "=== NGINX SERVER BLOCK CREATION === \n"

# --- Remove default nginx site ---
DEFAULT_ENABLED="/etc/nginx/sites-enabled/default"
if [[ -L "$DEFAULT_ENABLED" || -f "$DEFAULT_ENABLED" ]]; then
    echo "Removing default Nginx site..."
    sudo rm -f "$DEFAULT_ENABLED"
    echo "Default site removed"
fi
echo

# --- Ask for input values ---
read -rp "Enter the SERVER_NAME (e.g. example.com): " SERVER_NAME
read -rp "Enter the PROXY_PORT (e.g. 3000): " PROXY_PORT
echo

AVAILABLE_PATH="/etc/nginx/sites-available/${SERVER_NAME}"
ENABLED_PATH="/etc/nginx/sites-enabled/${SERVER_NAME}"

echo "⚙️ Creating nginx configuration for:"
echo "   SERVER_NAME: $SERVER_NAME"
echo "   PROXY_PORT:  $PROXY_PORT"
echo -e "   FILENAME:    $SERVER_NAME \n"

# --- Check for existing file ---
if [[ -f "$AVAILABLE_PATH" ]]; then
    echo "⚠️  Config file already exists: $AVAILABLE_PATH"
    echo "Aborting to avoid overwrite."
    exit 1
fi

# --- Create configuration file ---
echo "⚙️ Writing nginx configuration file..."
sudo tee "$AVAILABLE_PATH" > /dev/null <<EOF
server {
    listen 80;
    server_name ${SERVER_NAME};

    # Default location (serves static file)
    location / {
        root /var/www/html;
        index index.html index.htm index.nginx-debian.html;
        try_files $uri $uri/ =404;
    }

    # API reverse proxy to localhost:${PROXY_PORT}
    location /api {
        proxy_pass http://localhost:${PROXY_PORT};
        proxy_http_version 1.1;

        # Headers for proper proxying
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host \$host:\$server_port;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF
echo -e "Config file created at $AVAILABLE_PATH \n"

# --- Create symbolic link ---
echo "⚙️ Linking configuration to sites-enabled..."
if [[ -L "$ENABLED_PATH" ]]; then
    echo -e "Symlink already exists: $ENABLED_PATH \n"
else
    sudo ln -s "$AVAILABLE_PATH" "$ENABLED_PATH"
    echo "Symlink created: $ENABLED_PATH \n"
fi

# --- HTTPS setup with Certbot ---
echo "=== HTTPS SETUP WITH CERTBOT ==="

if command -v certbot &>/dev/null; then
    echo "🔐 Requesting SSL certificate for ${SERVER_NAME}..."
    if sudo certbot --nginx -d "${SERVER_NAME}" --non-interactive --agree-tos -m admin@"${SERVER_NAME}" --redirect; then
        echo "HTTPS successfully enabled for ${SERVER_NAME}"

        # --- Configure auto-renewal using systemd timer ---
        echo "🕒 Enabling certbot systemd timer for auto-renewal..."
        sudo systemctl enable --now certbot.timer
        echo "Certbot systemd timer enabled"

    else
        echo "⚠️ Certbot failed to obtain certificate"
    fi
else
    echo "⚠️ Certbot not found! Skipping HTTPS setup."
fi
echo

# --- Test nginx configuration ---
echo "⚙️ Testing nginx configuration syntax..."
if sudo nginx -t; then
    echo "Nginx configuration syntax is valid"
else
    echo "⚠️ Nginx configuration test failed"
    exit 1
fi
echo

# --- Reload nginx once at the end ---
echo "⚙️ Reloading nginx service..."
sudo systemctl reload nginx.service
echo "Nginx reloaded successfully"
echo

echo "🚀 Nginx server block for '${SERVER_NAME}' is now active!"
echo "📄 Config:  $AVAILABLE_PATH"
echo "🔗 Symlink: $ENABLED_PATH"

echo -e "✅ Setup complete! \n\n"
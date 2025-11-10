#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ Provisioning failed at line $LINENO"; exit 1' ERR

echo "=== MAIN PROVISIONING SCRIPT ==="

# --- Optional pre-flight checks ---
read -rp "Do you want to perform pre-flight checks? (SSH to GitHub & domain reachability) [y/N]: " RUN_CHECKS
RUN_CHECKS="${RUN_CHECKS,,}"  # convert to lowercase

if [[ "$RUN_CHECKS" == "y" ]]; then
    echo "Running pre-flight checks..."
    echo

    # --- Define ED25519 key ---
    ED25519_KEY="$HOME/.ssh/id_ed25519"

    # --- Test SSH connection to GitHub using specific ED25519 key ---
    echo "🔐 Testing SSH connection to GitHub with ED25519 key..."
    export GIT_SSH_COMMAND="ssh -i $ED25519_KEY -o IdentitiesOnly=yes"
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo "SSH connection to GitHub is OK"
    else
        echo "⚠️ SSH authentication failed. Make sure your ED25519 SSH key is added to GitHub and ssh-agent is running."
        exit 1
    fi
    echo

    # --- Ask for domain name to test ---
    read -rp "Enter the domain to check (e.g., example.com): " DOMAIN

    # --- Test if domain resolves via DNS ---
    echo "🌐 Checking DNS resolution for $DOMAIN..."
    if ! host "$DOMAIN" >/dev/null 2>&1; then
        echo "⚠️ Domain '$DOMAIN' could not be resolved. Check your DNS settings."
        exit 1
    fi
    echo "✅ Domain resolves via DNS"

    # --- Test if domain is reachable (HTTP ping) ---
    echo "🔄 Testing if domain '$DOMAIN' is reachable..."
    if ! curl -s --head "http://$DOMAIN" >/dev/null; then
        echo "⚠️ Domain '$DOMAIN' is not reachable via HTTP."
        exit 1
    fi
    echo "Domain '$DOMAIN' is reachable"

    echo -e "✅ Pre-flight checks passed! \n\n"
else
    echo "Skipping pre-flight checks. Continuing with provisioning...\n\n"
fi
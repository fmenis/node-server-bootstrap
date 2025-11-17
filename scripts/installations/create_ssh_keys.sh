#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ SSH agent setup failed at line $LINENO"; exit 1' ERR

echo "=== SSH keys SETUP ==="

# --- Ask for email for SSH key ---
read -rp "Enter the email to associate with the SSH key: " SSH_EMAIL

# --- Ask for passphrase (optional) ---
read -rsp "Enter passphrase for SSH key (leave empty for no passphrase): " SSH_PASSPHRASE
echo

echo "=== Checking ssh-agent availability ==="

# --- Check if ssh-agent is reachable ---
if ! ssh-add -l >/dev/null 2>&1; then
    echo "⚠️  ssh-agent not reachable. Starting a new agent..."
    eval "$(ssh-agent -s)"
    echo "ssh-agent started"
else
    echo "ssh-agent is reachable"
fi
echo

# --- Define default ED25519 key ---
ED25519_KEY="$HOME/.ssh/id_ed25519"
ED25519_PUB="$ED25519_KEY.pub"

# --- Create ED25519 key if it doesn't exist ---
if [[ ! -f "$ED25519_KEY" ]]; then
    echo "🔑 SSH key '$ED25519_KEY' not found. Creating a new ED25519 key..."
    ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$ED25519_KEY" -N "$SSH_PASSPHRASE"
    echo "ED25519 SSH key created: $ED25519_KEY"
else
    echo "ED25519 SSH key already exists: $ED25519_KEY"
fi
echo

# --- Print public key for GitHub ---
echo "📋 Your public SSH key is:"
cat "$ED25519_PUB"
echo
echo "🔗 Copy this key and add it to your GitHub account (https://github.com/settings/keys)."
read -rp "Press ENTER after you have added the key to GitHub to continue..." _

# --- Add the key to the ssh-agent ---
if ssh-add -l 2>/dev/null | grep -q "$ED25519_KEY"; then
    echo "SSH key '$ED25519_KEY' is already added to the agent"
else
    echo "🔑 Adding SSH key '$ED25519_KEY' to ssh-agent..."
    ssh-add "$ED25519_KEY"
    echo "SSH key added to agent"
fi
echo

echo -e "✅ SSH keys setup complete! \n\n"
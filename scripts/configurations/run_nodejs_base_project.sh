#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ Git clone/pull failed at line $LINENO"; exit 1' ERR

echo "=== GITHUB REPOSITORY CLONE OR UPDATE (SSH ONLY, ED25519) ==="

# --- Ask for input values ---
read -rp "Enter your GitHub repository (username/repo): " REPO
read -rp "Enter the target directory where to clone/update: " TARGET_DIR
echo

# --- Define the ED25519 key path ---
ED25519_KEY="$HOME/.ssh/id_ed25519"

# --- Ensure the key exists ---
if [[ ! -f "$ED25519_KEY" ]]; then
    echo "⚠️ ED25519 key not found: $ED25519_KEY"
    echo "Please run the SSH setup script first to create and add it to ssh-agent."
    exit 1
fi

# --- Set GIT_SSH_COMMAND to use the ED25519 key ---
export GIT_SSH_COMMAND="ssh -i $ED25519_KEY -o IdentitiesOnly=yes"

# --- Determine Git SSH URL ---
GIT_URL="git@github.com:${REPO}.git"

# --- Clone or pull repository ---
if [[ -d "$TARGET_DIR" ]]; then
    if [[ -d "$TARGET_DIR/.git" ]]; then
        echo "🔄 Directory exists and is a git repository. Pulling latest changes..."
        cd "$TARGET_DIR"
        git pull
        echo "✅ Repository updated successfully"
    else
        echo "⚠️ Directory '$TARGET_DIR' exists but is not a git repository. Aborting to avoid overwrite."
        exit 1
    fi
else
    # --- Create parent directory if necessary ---
    PARENT_DIR=$(dirname "$TARGET_DIR")
    if [[ ! -d "$PARENT_DIR" ]]; then
        echo "📂 Parent directory '$PARENT_DIR' does not exist. Creating..."
        mkdir -p "$PARENT_DIR"
        echo "✅ Parent directory created"
    fi

    # --- Clone the repository ---
    echo "🔄 Cloning repository '$REPO' into '$TARGET_DIR' using ED25519 SSH key..."
    git clone "$GIT_URL" "$TARGET_DIR"
    echo "✅ Repository cloned successfully"
fi

echo -e "🚀 Repository '$REPO' is now available in '$TARGET_DIR'\n\n"

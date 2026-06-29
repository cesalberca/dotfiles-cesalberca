#!/usr/bin/env bash
# 1password topic. Links this plugin's agent.toml (which lists every vault) to
# the single file the 1Password SSH agent reads. The agent has no include/merge
# directive, so all vaults live in one file, owned entirely by this plugin.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/agent.toml"
DEST_DIR="$HOME/.config/1Password/ssh"
DEST="$DEST_DIR/agent.toml"

mkdir -p "$DEST_DIR"

ln -sfn "$SRC" "$DEST"
echo "Linked $DEST to $SRC"
echo "Restart the 1Password app (or toggle the SSH agent) to reload."

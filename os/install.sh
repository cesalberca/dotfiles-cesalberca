#!/usr/bin/env bash
set -euo pipefail

# Create hushlogin
touch ~/.hushlogin

# Install oh my zsh
if [[ ! -d ~/.oh-my-zsh ]]; then
    export RUNZSH=no
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Change MacOS configuration
source "$(dirname "$0")/.macos"

# Install app store's apps (idempotent)
if ! mas list | grep -q 1263070803; then
    mas install 1263070803 # Lungo
fi

#!/usr/bin/env bash
set -euo pipefail

# Link Claude Code config + hooks into ~/.claude.
#
# The dotfiles framework only symlinks top-level *.symlink files into $HOME
# (it basenames the target). Claude needs nested targets under ~/.claude/,
# so we link them here instead. Runs on `dotfiles install`.

TOPIC_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR/hooks"

link () {
    local src="$1" dst="$2"
    # Back up a real file/dir that isn't already a symlink we manage.
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        local backup="$dst.bak.$(date +%s)"
        echo "Backing up existing $dst -> $backup"
        mv "$dst" "$backup"
    fi
    ln -sfn "$src" "$dst"
    echo "Linked $dst -> $src"
}

chmod +x "$TOPIC_DIR"/hooks/*.sh

link "$TOPIC_DIR/settings.json"              "$CLAUDE_DIR/settings.json"
link "$TOPIC_DIR/hooks/no-em-dash.sh"        "$CLAUDE_DIR/hooks/no-em-dash.sh"
link "$TOPIC_DIR/hooks/no-em-dash-files.sh"  "$CLAUDE_DIR/hooks/no-em-dash-files.sh"
link "$TOPIC_DIR/hooks/no-arrows.sh"         "$CLAUDE_DIR/hooks/no-arrows.sh"
link "$TOPIC_DIR/hooks/no-arrows-files.sh"   "$CLAUDE_DIR/hooks/no-arrows-files.sh"

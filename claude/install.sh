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

# Skills: flat-link each skill dir into ~/.claude/skills/<name>.
#
# The repo organises skills by category (skills/<category>/<skill>/), but Claude
# discovers PERSONAL skills only FLAT at ~/.claude/skills/<skill>/. So we link
# each skill's basename, ignoring its category folder. Every skill dir name must
# therefore be globally unique across categories.
SKILLS_SRC="$TOPIC_DIR/skills"
SKILLS_DST="$CLAUDE_DIR/skills"

if [[ -d "$SKILLS_SRC" ]]; then
    mkdir -p "$SKILLS_DST"
    # Make any shipped skill scripts executable (bash 3.2 compatible glob).
    find "$SKILLS_SRC" -type f -name '*.sh' -exec chmod +x {} +

    seen=" "
    shopt -s nullglob
    for skill_dir in "$SKILLS_SRC"/*/*/; do
        skill_dir="${skill_dir%/}"
        [[ -f "$skill_dir/SKILL.md" ]] || continue
        name="$(basename "$skill_dir")"
        case "$seen" in
            *" $name "*)
                echo "ERROR: duplicate skill name '$name' across categories; names must be unique" >&2
                exit 1 ;;
        esac
        seen="$seen$name "
        link "$skill_dir" "$SKILLS_DST/$name"
    done
    shopt -u nullglob
fi

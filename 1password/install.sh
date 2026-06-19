#!/usr/bin/env bash
# 1password topic. Contributes THIS plugin's vault block to the SHARED
# 1Password SSH agent config at ~/.config/1Password/ssh/agent.toml.
#
# The 1Password agent reads exactly one file and has no include/merge directive,
# so plugins cannot each symlink their own agent.toml (last writer would win and
# clobber the others). Instead every plugin owns a marked block inside that one
# file. This script idempotently upserts the block whose contents are the
# sibling agent.toml fragment, and never touches blocks owned by other plugins.
#
# Plugin name and block contents are derived from the filesystem, so this script
# is identical across dotfiles-cesalberca, dotfiles-tii and dotfiles-ttcc.
set -euo pipefail

TOPIC_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN="$(basename "$(dirname "$TOPIC_DIR")")"
FRAGMENT="$TOPIC_DIR/agent.toml"

AGENT_DIR="$HOME/.config/1Password/ssh"
AGENT_TOML="$AGENT_DIR/agent.toml"
BEGIN="# >>> $PLUGIN >>>"
END="# <<< $PLUGIN <<<"
HEADER_SENTINEL="# Managed by dotplug 1password topics."

if [[ ! -f "$FRAGMENT" ]]; then
    echo "error: missing fragment $FRAGMENT" >&2
    exit 1
fi

mkdir -p "$AGENT_DIR"

# Older setups symlinked agent.toml. We now own a real, generated file that
# several plugins append to, so replace any symlink with a regular file.
if [[ -L "$AGENT_TOML" ]]; then
    echo "Replacing symlinked $AGENT_TOML with a managed regular file"
    rm "$AGENT_TOML"
fi

# Back up a pre-existing hand-written file once, before we take over managing it.
if [[ -f "$AGENT_TOML" ]] && ! grep -qF "$HEADER_SENTINEL" "$AGENT_TOML"; then
    backup="$AGENT_TOML.bak.$(date +%s)"
    echo "Backing up existing unmanaged $AGENT_TOML -> $backup"
    cp "$AGENT_TOML" "$backup"
    : > "$AGENT_TOML"
fi
touch "$AGENT_TOML"

# Ensure the managed header exists exactly once, at the top.
if ! grep -qF "$HEADER_SENTINEL" "$AGENT_TOML"; then
    tmp="$(mktemp)"
    {
        printf '%s\n' "$HEADER_SENTINEL"
        printf '%s\n' "# Each block is owned by the plugin named in its >>> markers. Edit that"
        printf '%s\n' "# plugin's 1password/agent.toml fragment, not this generated file."
        cat "$AGENT_TOML"
    } > "$tmp"
    mv "$tmp" "$AGENT_TOML"
fi

# Strip any previous block we own (exact full-line marker match, so the >>> / <<<
# characters need no regex escaping), then append a fresh block from the fragment.
stripped="$(mktemp)"
awk -v b="$BEGIN" -v e="$END" '
    $0==b {inblk=1; next}
    $0==e {inblk=0; next}
    !inblk {print}
' "$AGENT_TOML" > "$stripped"

{
    # Reprint stripped content normalized: collapse runs of blank lines to a
    # single blank and drop leading/trailing blanks, so repeated runs do not
    # accumulate whitespace where blocks were removed and re-appended.
    awk '
        NF==0 { blanks++; next }
        { if (printed && blanks) print ""; print; printed=1; blanks=0 }
    ' "$stripped"
    printf '\n%s\n' "$BEGIN"
    cat "$FRAGMENT"
    printf '%s\n' "$END"
} > "$AGENT_TOML"
rm -f "$stripped"

echo "Merged $PLUGIN block into $AGENT_TOML"

# Remind about (and, when the 1Password CLI is available and signed in, verify)
# every vault this fragment references, so a vault that still needs creating is
# not silently forgotten. A missing vault means the agent has no keys to serve.
vaults="$(grep -E '^[[:space:]]*vault[[:space:]]*=' "$FRAGMENT" | sed -E 's/.*=[[:space:]]*"([^"]+)".*/\1/' || true)"
while IFS= read -r vault; do
    [[ -z "$vault" ]] && continue
    if command -v op >/dev/null 2>&1 && op vault list >/dev/null 2>&1; then
        if op vault get "$vault" >/dev/null 2>&1; then
            echo "  [ok] 1Password vault \"$vault\" exists."
        else
            echo "  [ACTION NEEDED] 1Password vault \"$vault\" was not found in your account."
            echo "                  Create it in the 1Password app and add this org's SSH key item,"
            echo "                  then re-run so the agent can serve it."
        fi
    else
        echo "  [reminder] make sure the 1Password vault \"$vault\" exists and holds this org's SSH key."
        echo "             (sign in to the 1Password CLI 'op' to have this verified automatically.)"
    fi
done <<< "$vaults"

echo "Restart the 1Password app (or toggle the SSH agent) to reload, then:"
echo "  SSH_AUTH_SOCK=~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ssh-add -l"

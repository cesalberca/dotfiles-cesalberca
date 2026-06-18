#!/usr/bin/env bash
# PreToolUse hook (Write|Edit|MultiEdit) — deterministically strip em (—) and
# en (–) dashes from text being written to disk, replacing each with a regular
# hyphen (-).
#
# Complements no-em-dash.sh: that one guards chat output by instruction; this
# one guarantees files never receive the characters even if the model slips.
#
# Only the *new* content is rewritten — Write.content, Edit.new_string, and
# MultiEdit.edits[].new_string. old_string is left untouched so edits still
# match the existing file exactly. Permission decision is left to the normal
# flow (we emit updatedInput only, never force-allow).

command -v jq &>/dev/null || exit 0

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

case "$TOOL" in
  Write|Edit|MultiEdit) ;;
  *) exit 0 ;;
esac

# "—"/"–" in a jq string literal are the literal dash chars, used as
# (non-meta) regex patterns — a safe literal match.
JQ_FILTER='
  def strip: gsub("—";"-") | gsub("–";"-");
  .tool_input
  | (if has("content")    then .content    |= strip else . end)
  | (if has("new_string") then .new_string |= strip else . end)
  | (if has("edits")      then .edits      |= map(if has("new_string") then .new_string |= strip else . end) else . end)
'

ORIGINAL_INPUT=$(echo "$INPUT" | jq -c '.tool_input')
UPDATED_INPUT=$(echo "$INPUT" | jq -c "$JQ_FILTER")

# No dashes found — pass through unchanged.
[ "$ORIGINAL_INPUT" = "$UPDATED_INPUT" ] && exit 0

jq -n --argjson updated "$UPDATED_INPUT" '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "updatedInput": $updated
  }
}'

#!/usr/bin/env bash
# PreToolUse hook (Write|Edit|MultiEdit) — deterministic backstop that rewrites
# Unicode arrow glyphs to their ASCII equivalents in text headed to disk.
#
#   ↔ ⟷ ⇔        -> <->
#   ⇒ ⟹          -> =>
#   ⇐ ⟸          -> <=
#   → ⟶ ➜ ➔ ➝ ↦ ⇨ -> ->
#   ← ⟵          -> <-
#
# Like no-em-dash-files.sh: only new content is rewritten (Write.content,
# Edit.new_string, MultiEdit.edits[].new_string); old_string is left untouched
# so edits keep matching the file. Requires jq; no-ops if absent. Permission
# decision is left to the normal flow (updatedInput only, never force-allow).

command -v jq &>/dev/null || exit 0

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

case "$TOOL" in
  Write|Edit|MultiEdit) ;;
  *) exit 0 ;;
esac

# Replacements target distinct codepoints and emit only ASCII, so no gsub can
# feed another — order is irrelevant.
JQ_FILTER='
  def strip:
      gsub("↔";"<->") | gsub("⟷";"<->") | gsub("⇔";"<->")
    | gsub("⇒";"=>")  | gsub("⟹";"=>")
    | gsub("⇐";"<=")  | gsub("⟸";"<=")
    | gsub("→";"->")  | gsub("⟶";"->") | gsub("➜";"->") | gsub("➔";"->") | gsub("➝";"->") | gsub("↦";"->") | gsub("⇨";"->")
    | gsub("←";"<-")  | gsub("⟵";"<-");
  .tool_input
  | (if has("content")    then .content    |= strip else . end)
  | (if has("new_string") then .new_string |= strip else . end)
  | (if has("edits")      then .edits      |= map(if has("new_string") then .new_string |= strip else . end) else . end)
'

ORIGINAL_INPUT=$(echo "$INPUT" | jq -c '.tool_input')
UPDATED_INPUT=$(echo "$INPUT" | jq -c "$JQ_FILTER")

[ "$ORIGINAL_INPUT" = "$UPDATED_INPUT" ] && exit 0

jq -n --argjson updated "$UPDATED_INPUT" '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "updatedInput": $updated
  }
}'

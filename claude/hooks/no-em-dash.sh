#!/usr/bin/env bash
# UserPromptSubmit hook — suppress em/en dashes in generated text.
#
# stdout from a UserPromptSubmit hook (exit 0) is injected into the model's
# context for that turn. We use it to re-assert a hard style rule on every
# prompt so the model never emits em (—) or en (–) dashes.
#
# Note: no hook event can rewrite the assistant's chat output after the fact,
# so this is enforced by instruction, not by post-processing. For text written
# to files you can add a PreToolUse Write|Edit guard if you want it deterministic.

cat <<'EOF'
[style] Never use em dashes (—) or en dashes (–) anywhere in your output or in any text you generate: prose, code comments, commit messages, docs, and file contents. Replace them with a regular hyphen (-), a comma, a colon, parentheses, or split into separate sentences. Do not emit the characters — or – under any circumstances.
EOF

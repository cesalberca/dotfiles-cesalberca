#!/usr/bin/env bash
# UserPromptSubmit hook — keep Unicode arrow glyphs out of public-facing text.
#
# stdout from a UserPromptSubmit hook (exit 0) is injected into the turn's
# context, so this re-asserts the rule every prompt. This is the layer that
# covers text the model produces but never writes to a file with Write/Edit —
# commit messages, PR titles/bodies, issue comments, release notes, changelogs.

cat <<'EOF'
[style] Never use Unicode arrow glyphs (→ ← ↑ ↓ ↔ ⇒ ⇐ ⇔ ⟶ ⟵ ➜ ➔ ↦, or any other arrow character) in public-facing text: commit messages, PR titles and bodies, issue comments, release notes, changelogs, docs, and UI copy. Use a plain word ("to", "leads to", "then") or an ASCII equivalent (->, =>, <-, <->) instead. Do not emit arrow characters under any circumstances.
EOF

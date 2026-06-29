#!/usr/bin/env bash
# UserPromptSubmit hook: prefer natural language over arrows in prose.
#
# stdout from a UserPromptSubmit hook (exit 0) is injected into the turn's
# context, so this re-asserts the rule every prompt. It covers text the model
# produces but never writes to a file with Write/Edit: commit messages, PR
# titles/bodies, issue comments, release notes, changelogs.

cat <<'EOF'
[style] In prose, do not use arrows to connect ideas: neither Unicode arrow glyphs (arrows pointing in any direction) nor ASCII arrow strings (->, =>, <-, <->). This covers commit messages, PR titles and bodies, issue comments, release notes, changelogs, docs, UI copy, and skill or documentation text. Use natural language instead: "to", "then", "leads to", "becomes", "results in", or rephrase the sentence. ASCII arrows are acceptable only inside code, where they are real syntax (for example => in JavaScript or -> in Rust).
EOF

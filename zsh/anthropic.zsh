# Route Claude Code (and any Anthropic SDK tool) through the Vercel AI Gateway using the Claude
# subscription, so usage and traces show up in the Vercel dashboard while the model access stays
# on the Anthropic subscription. The gateway API key is read from 1Password at shell startup, so
# it never lives in this repo. If 1Password is locked or the item is missing, both vars stay unset
# and Claude Code falls back to talking to Anthropic directly (no breakage).
#
# The key lives in the 1Password "Vercel AI Gateway" item (Personal vault), referenced by its
# stable item id so renaming the item won't break this.
_ai_gateway_key="$(op read 'op://Personal/6vjscurowteuvt2otcspt7rcou/credential' 2>/dev/null)"
if [[ -n "$_ai_gateway_key" ]]; then
  export ANTHROPIC_BASE_URL="https://ai-gateway.vercel.sh"
  export ANTHROPIC_CUSTOM_HEADERS="x-ai-gateway-api-key: Bearer ${_ai_gateway_key}"
fi
unset _ai_gateway_key

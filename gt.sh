# gt.sh — LLM provider switcher for Claude Code
# Usage: gt [g|k|m|o|c|s]

# ── User config ────────────────────────────────────────────────────────────────
# GLM (Z.ai) — https://api.z.ai
GT_GLM_AUTH_TOKEN="${GT_GLM_AUTH_TOKEN:-YOUR_GLM_API_KEY}"
GT_GLM_BASE_URL="https://api.z.ai/api/anthropic"
GT_GLM_HAIKU_MODEL="glm-4.7-flash"
GT_GLM_SONNET_MODEL="glm-5v-turbo"
GT_GLM_OPUS_MODEL="glm-5.1"

# Kimi (Moonshot) — https://api.kimi.com
GT_KIMI_AUTH_TOKEN="${GT_KIMI_AUTH_TOKEN:-YOUR_KIMI_API_KEY}"
GT_KIMI_BASE_URL="https://api.kimi.com/coding/"
GT_KIMI_MODEL="kimi-k2.6-code-preview"

# MiniMax — https://api.minimax.io
GT_MINIMAX_AUTH_TOKEN="${GT_MINIMAX_AUTH_TOKEN:-YOUR_MINIMAX_API_KEY}"
GT_MINIMAX_BASE_URL="https://api.minimax.io/anthropic"
GT_MINIMAX_MODEL="MiniMax-M2.7-highspeed"

# OpenRouter — https://openrouter.ai
GT_OPENROUTER_AUTH_TOKEN="${GT_OPENROUTER_AUTH_TOKEN:-YOUR_OPENROUTER_API_KEY}"
GT_OPENROUTER_BASE_URL="https://openrouter.ai/api"
GT_OPENROUTER_MODEL="qwen/qwen3.6-plus:free"
# ── End user config ────────────────────────────────────────────────────────────

_GT_SYNC_VARS=(ANTHROPIC_AUTH_TOKEN ANTHROPIC_API_KEY ANTHROPIC_BASE_URL ANTHROPIC_VERSION
               ANTHROPIC_MODEL API_TIMEOUT_MS ANTHROPIC_DEFAULT_HAIKU_MODEL
               ANTHROPIC_DEFAULT_SONNET_MODEL ANTHROPIC_DEFAULT_OPUS_MODEL
               CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC)

# Sync named env vars into tmux's global environment so that teammate panes
# spawned by Claude Code inherit them automatically.
# When a variable is unset in the shell, it is also removed from tmux's global env.
_gt_tmux_sync() {
  [ -z "$TMUX" ] && return 0
  local var
  for var in "$@"; do
    if eval "[ -n \"\${$var+x}\" ]"; then
      tmux set-environment -g "$var" "$(eval echo \"\$$var\")"
    else
      tmux set-environment -gu "$var" 2>/dev/null
    fi
  done
}

gt() {
  case "$1" in
    "g")  # GLM mode (Z.ai)
      export ANTHROPIC_AUTH_TOKEN="$GT_GLM_AUTH_TOKEN"
      export ANTHROPIC_BASE_URL="$GT_GLM_BASE_URL"
      export ANTHROPIC_VERSION="2023-06-01"
      export API_TIMEOUT_MS="3000000"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL="$GT_GLM_HAIKU_MODEL"
      export ANTHROPIC_DEFAULT_SONNET_MODEL="$GT_GLM_SONNET_MODEL"
      export ANTHROPIC_DEFAULT_OPUS_MODEL="$GT_GLM_OPUS_MODEL"
      export ANTHROPIC_MODEL="$GT_GLM_OPUS_MODEL"
      unset CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
      _gt_tmux_sync "${_GT_SYNC_VARS[@]}"
      echo "GLM mode"
      ;;

    "k")  # Kimi mode (Moonshot)
      export ANTHROPIC_AUTH_TOKEN="$GT_KIMI_AUTH_TOKEN"
      export ANTHROPIC_BASE_URL="$GT_KIMI_BASE_URL"
      export ANTHROPIC_MODEL="$GT_KIMI_MODEL"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL="$GT_KIMI_MODEL"
      export ANTHROPIC_DEFAULT_SONNET_MODEL="$GT_KIMI_MODEL"
      export ANTHROPIC_DEFAULT_OPUS_MODEL="$GT_KIMI_MODEL"
      unset ANTHROPIC_VERSION
      unset API_TIMEOUT_MS
      unset CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
      _gt_tmux_sync "${_GT_SYNC_VARS[@]}"
      echo "Kimi mode"
      ;;

    "m")  # MiniMax mode
      export ANTHROPIC_AUTH_TOKEN="$GT_MINIMAX_AUTH_TOKEN"
      export ANTHROPIC_BASE_URL="$GT_MINIMAX_BASE_URL"
      export ANTHROPIC_MODEL="$GT_MINIMAX_MODEL"
      export API_TIMEOUT_MS="3000000"
      export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
      export ANTHROPIC_DEFAULT_HAIKU_MODEL="$GT_MINIMAX_MODEL"
      export ANTHROPIC_DEFAULT_SONNET_MODEL="$GT_MINIMAX_MODEL"
      export ANTHROPIC_DEFAULT_OPUS_MODEL="$GT_MINIMAX_MODEL"
      unset ANTHROPIC_VERSION
      _gt_tmux_sync "${_GT_SYNC_VARS[@]}"
      echo "MiniMax mode"
      ;;

    "o")  # OpenRouter mode
      export ANTHROPIC_AUTH_TOKEN="$GT_OPENROUTER_AUTH_TOKEN"
      export ANTHROPIC_API_KEY=""
      export ANTHROPIC_BASE_URL="$GT_OPENROUTER_BASE_URL"
      export ANTHROPIC_MODEL="$GT_OPENROUTER_MODEL"
      export API_TIMEOUT_MS="3000000"
      export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
      export ANTHROPIC_DEFAULT_HAIKU_MODEL="$GT_OPENROUTER_MODEL"
      export ANTHROPIC_DEFAULT_SONNET_MODEL="$GT_OPENROUTER_MODEL"
      export ANTHROPIC_DEFAULT_OPUS_MODEL="$GT_OPENROUTER_MODEL"
      unset ANTHROPIC_VERSION
      _gt_tmux_sync "${_GT_SYNC_VARS[@]}"
      echo "OpenRouter mode"
      ;;

    "c")  # Claude mode (Anthropic native — uses ~/.claude/ OAuth credentials)
      unset ANTHROPIC_AUTH_TOKEN
      unset ANTHROPIC_API_KEY
      unset ANTHROPIC_BASE_URL
      unset ANTHROPIC_VERSION
      unset ANTHROPIC_MODEL
      unset API_TIMEOUT_MS
      unset ANTHROPIC_DEFAULT_HAIKU_MODEL
      unset ANTHROPIC_DEFAULT_SONNET_MODEL
      unset ANTHROPIC_DEFAULT_OPUS_MODEL
      unset CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
      _gt_tmux_sync "${_GT_SYNC_VARS[@]}"
      echo "Claude mode"
      ;;

    "s"|"")
      if [[ "$ANTHROPIC_BASE_URL" == *"z.ai"* ]]; then
        echo "GLM ($ANTHROPIC_DEFAULT_SONNET_MODEL)"
      elif [[ "$ANTHROPIC_BASE_URL" == *"kimi.com"* ]]; then
        echo "Kimi ($ANTHROPIC_DEFAULT_SONNET_MODEL)"
      elif [[ "$ANTHROPIC_BASE_URL" == *"minimax"* ]]; then
        echo "MiniMax ($ANTHROPIC_MODEL)"
      elif [[ "$ANTHROPIC_BASE_URL" == *"openrouter"* ]]; then
        echo "OpenRouter ($ANTHROPIC_MODEL)"
      else
        echo "Claude (Anthropic)"
      fi
      ;;

    *)
      echo "Usage: gt [g|k|m|o|c|s]"
      echo "  g — GLM mode (Z.ai)"
      echo "  k — Kimi mode (Moonshot)"
      echo "  m — MiniMax mode"
      echo "  o — OpenRouter mode"
      echo "  c — Claude mode (Anthropic)"
      echo "  s — show current mode (default)"
      ;;
  esac
}

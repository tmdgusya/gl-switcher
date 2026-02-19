# gt.sh — LLM provider switcher for Claude Code
# Supports GLM (Z.ai), Kimi (Moonshot), and Claude (Anthropic native)
# Compatible with both zsh and bash.
#
# Usage: source this file in your .zshrc or .bashrc, then run:
#   gt g   — switch to GLM mode
#   gt k   — switch to Kimi mode
#   gt c   — switch to Claude (Anthropic) mode
#   gt s   — show current mode (default)
#
# Config: set your API keys in the environment variables below
# or export them before sourcing this file.

# ── User config ────────────────────────────────────────────────────────────────
# GLM (Z.ai) — https://api.z.ai
GT_GLM_AUTH_TOKEN="${GT_GLM_AUTH_TOKEN:-your-z-ai-token-here}"
GT_GLM_BASE_URL="${GT_GLM_BASE_URL:-https://api.z.ai/api/anthropic}"
GT_GLM_HAIKU_MODEL="${GT_GLM_HAIKU_MODEL:-glm-4.7-flash}"
GT_GLM_SONNET_MODEL="${GT_GLM_SONNET_MODEL:-glm-4.7}"
GT_GLM_OPUS_MODEL="${GT_GLM_OPUS_MODEL:-glm-5}"

# Kimi (Moonshot) — https://api.kimi.com
GT_KIMI_AUTH_TOKEN="${GT_KIMI_AUTH_TOKEN:-your-kimi-token-here}"
GT_KIMI_BASE_URL="${GT_KIMI_BASE_URL:-https://api.kimi.com/coding/}"
GT_KIMI_MODEL="${GT_KIMI_MODEL:-kimi-k2.5}"
# ── End user config ────────────────────────────────────────────────────────────

_GT_SYNC_VARS=(ANTHROPIC_AUTH_TOKEN ANTHROPIC_BASE_URL ANTHROPIC_VERSION ANTHROPIC_MODEL
               API_TIMEOUT_MS ANTHROPIC_DEFAULT_HAIKU_MODEL ANTHROPIC_DEFAULT_SONNET_MODEL
               ANTHROPIC_DEFAULT_OPUS_MODEL)

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
      unset ANTHROPIC_MODEL
      _gt_tmux_sync "${_GT_SYNC_VARS[@]}"
      echo "🔹 GLM mode active"
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
      _gt_tmux_sync "${_GT_SYNC_VARS[@]}"
      echo "🟣 Kimi mode active"
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
      _gt_tmux_sync "${_GT_SYNC_VARS[@]}"
      echo "🔸 Claude mode active (Anthropic)"
      ;;

    "s"|"")  # Show current mode (default)
      if [[ "$ANTHROPIC_BASE_URL" == *"z.ai"* ]]; then
        echo "🔹 Current: GLM ($ANTHROPIC_DEFAULT_SONNET_MODEL)"
      elif [[ "$ANTHROPIC_BASE_URL" == *"kimi.com"* ]]; then
        echo "🟣 Current: Kimi ($ANTHROPIC_DEFAULT_SONNET_MODEL)"
      else
        echo "🔸 Current: Claude (Anthropic)"
      fi
      ;;

    *)
      echo "Usage: gt [g|k|c|s]"
      echo "  g — GLM mode (Z.ai)"
      echo "  k — Kimi mode (Moonshot)"
      echo "  c — Claude mode (Anthropic)"
      echo "  s — show current mode (default)"
      ;;
  esac
}

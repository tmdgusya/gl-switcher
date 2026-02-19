# gt — LLM Provider Switcher for Claude Code

`gt` is a tiny zsh helper that lets you instantly switch Claude Code between different LLM providers (GLM, Kimi, Claude native) from your terminal — including **automatic tmux environment propagation** so spawned teammate panes inherit the right credentials.

## Why this exists

Claude Code supports alternative backends via `ANTHROPIC_BASE_URL` and `ANTHROPIC_AUTH_TOKEN`. But when Claude Code spawns teammate agents in new tmux panes, those panes inherit tmux's **global** environment, not your current shell's exported variables. Without syncing, teammates start without credentials and fail to authenticate.

`gt` solves this by calling `tmux set-environment -g` every time you switch modes, so any new pane created afterwards — including teammate panes spawned by Claude Code — inherits the correct credentials automatically.

## Supported providers

| Mode | Provider | Auth |
|------|----------|------|
| `gt g` | [GLM / Z.ai](https://api.z.ai) | `ANTHROPIC_AUTH_TOKEN` |
| `gt k` | [Kimi / Moonshot](https://api.kimi.com) | `ANTHROPIC_AUTH_TOKEN` |
| `gt c` | Anthropic (Claude native) | `~/.claude/` OAuth credentials |

## Installation

### 1. Clone or download

```bash
git clone https://github.com/yourname/gt-switcher.git ~/gt-switcher
# or just download gt.zsh directly
```

### 2. Set your API keys

Either export them before sourcing, or edit the config block at the top of `gt.zsh`:

```zsh
# In your .zshrc, before sourcing gt.zsh:
export GT_GLM_AUTH_TOKEN="your-z-ai-token"
export GT_KIMI_AUTH_TOKEN="your-kimi-token"
```

Or edit `gt.zsh` directly:

```zsh
GT_GLM_AUTH_TOKEN="your-z-ai-token-here"
GT_KIMI_AUTH_TOKEN="your-kimi-token-here"
```

### 3. Source in your `.zshrc`

```zsh
source ~/gt-switcher/gt.zsh
```

Then reload:

```bash
source ~/.zshrc
```

## Usage

```bash
gt g    # Switch to GLM (Z.ai)
gt k    # Switch to Kimi (Moonshot)
gt c    # Switch to Claude (Anthropic)
gt s    # Show current mode
gt      # Same as gt s
```

## How the tmux sync works

```
gt g
 └─ export ANTHROPIC_AUTH_TOKEN, ANTHROPIC_BASE_URL, ... (current shell)
 └─ tmux set-environment -g ANTHROPIC_AUTH_TOKEN ...     (tmux global)

Claude Code starts → spawns teammate → tmux new-pane
 └─ new pane inherits tmux global env
 └─ ANTHROPIC_AUTH_TOKEN present → authentication succeeds ✓

gt c
 └─ unset all custom vars (current shell)
 └─ tmux set-environment -gu ...  (removes from tmux global)
 └─ Claude Code uses ~/.claude/ OAuth credentials instead ✓
```

The `_gt_tmux_sync` helper is a no-op when you're not inside a tmux session, so `gt` works fine in plain terminals too.

## Customizing models

Override the default model names via env vars before sourcing:

```zsh
export GT_GLM_HAIKU_MODEL="glm-4.7-flash"
export GT_GLM_SONNET_MODEL="glm-5"
export GT_GLM_OPUS_MODEL="glm-5"

export GT_KIMI_MODEL="kimi-k2.5"
```

Claude Code reads `ANTHROPIC_DEFAULT_HAIKU_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, and `ANTHROPIC_DEFAULT_OPUS_MODEL` to map its internal model tiers to provider-specific model names.

## Note on model names in teammate logs

When Claude Code spawns teammate agents in GLM mode, the `--model` flag in the spawned command may still show `claude-opus-4-6` or `claude-sonnet-4-6`. This is expected — the Z.ai proxy automatically maps these Anthropic model IDs to the corresponding GLM models (e.g. `claude-opus-4-6` → `glm-5`). The actual inference runs on GLM, not on Anthropic's models.

## Requirements

- zsh
- [tmux](https://github.com/tmux/tmux) (optional — sync is skipped outside tmux)
- [Claude Code](https://github.com/anthropics/claude-code)

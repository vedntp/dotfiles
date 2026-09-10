# CLAUDE.md

## Overview

Zsh configuration using Oh My Zsh with the Powerlevel10k theme. The tracked
shell config is `mac/.zshrc`, stowed to `~/.zshrc`.

## Plugins

```text
git zsh-autosuggestions fzf fzf-tab z colored-man-pages zsh-syntax-highlighting
```

On macOS, `.zshrc` also appends:

```text
macos brew
```

## Secrets Management

`~/.config/zsh/.zshenv.local` contains machine-local secrets and is gitignored.
It is loaded at the top of `.zshrc` before p10k instant prompt.

Known referenced env vars include:

- `GEMINI_API_KEY` - Google Gemini API
- `ZAI_AUTH_TOKEN` - Z.AI authentication token if local GLM tooling is enabled

## Custom Functions

**ranger()** - Wraps ranger to cd to the last directory on quit. Use via the
`rr` alias.

**fr()** - Recent files picker using Neovim's oldfiles plus fzf, filtered to
existing files only.

The tracked `.zshrc` does not currently define `glm()`. If `glm` is available,
it comes from local shell config or another installed command.

## Key Aliases

| Alias | Command | Purpose |
|-------|---------|---------|
| `rr` | `ranger` | File manager with cd-on-quit |
| `vim`, `vi` | `nvim` | Neovim |
| `py` | `.venv/bin/python3` | Local venv Python |
| `fim` | `vim $(fzf)` | Fuzzy find and edit |
| `fopen` | `open "$(fzf)"` | Fuzzy find and open |
| `fcd` | cd to fzf selection | Fuzzy cd |
| `tw` | `task` | Taskwarrior |
| `caff`/`uncaff` | caffeinate control | Keep-awake scripts |
| `mynet`/`offmynet` | network scripts | Fast network toggle |
| `gsdc` | `gsd -c` | GSD CLI shortcut |
| `gfix` | `gcloud auth application-default login` | Refresh ADC auth |
| `cxl` | `codex -p lean --dangerously-bypass-approvals-and-sandbox` | Codex lean profile with approvals and sandbox disabled |

### Claude Code Aliases

| Alias | Command | Purpose |
|-------|---------|---------|
| `cl` | `claude` | Launch Claude Code |
| `cld` | `claude --dangerously-skip-permissions --model 'claude-opus-4-8[1m]' --effort high` | Opus/high effort |
| `clds` | `claude --dangerously-skip-permissions --model sonnet --effort high` | Sonnet/high effort |
| `cldr` | `claude --resume --dangerously-skip-permissions` | Resume with skipped permissions |
| `cldc` | `claude --continue --dangerously-skip-permissions` | Continue with skipped permissions |
| `cldp` | `claude --dangerously-skip-permissions --model sonnet --effort medium -p` | Print-mode Sonnet |
| `ccv` | `claude --strict-mcp-config --mcp-config ~/.claude/mcp-none.json` | Claude without MCP servers |
| `ccvcd` | `ccv` + continue + skipped permissions | Continue without MCP servers |
| `ccvd` | `ccv` + skipped permissions | Skipped permissions without MCP servers |

### Usage Aliases

| Alias | Command | Purpose |
|-------|---------|---------|
| `ccu` | `ccusage --since $(date +%Y%m%d) -b` | Today's usage with breakdown |
| `ccuw` | `ccusage weekly -b` | Weekly usage |
| `ccum` | `ccusage monthly -b` | Monthly usage |
| `ccup` | `ccusage -i` | Usage by project |

## Environment

- `EDITOR` / `VISUAL` = `nvim`
- Bat selects the built-in `ansi` theme in `~/.config/bat/config`
- `TERM` = `xterm-256color`
- direnv hook enabled
- Claude Code no-flicker and tmux truecolor env flags are enabled
- `ENABLE_CLAUDEAI_MCP_SERVERS=false` keeps claude.ai MCP servers out of Claude Code

## Prompt Configuration

Powerlevel10k is configured via `mac/.p10k.zsh`, stowed to `~/.p10k.zsh`. The
current wizard-generated setup uses the Lean style: one compact line,
transparent segment backgrounds, space separators, icons before content, and
transient prompts. The left side shows directory, Git status, and the prompt
character; the OS icon is disabled. The right side retains status and
environment/context segments, while the clock is disabled.

## Syntax Highlighting

zsh-syntax-highlighting uses its plugin defaults; the tracked `.zshrc` does not
override semantic highlight colors.

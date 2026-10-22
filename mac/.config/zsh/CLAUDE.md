# CLAUDE.md

## Overview

Plain zsh, no framework, with a Starship prompt. The tracked shell config is
`mac/.zshrc`, stowed to `~/.zshrc`. Oh My Zsh, Powerlevel10k and direnv were
removed on 2026-10-19; the "SHELL BASICS" block in `.zshrc` replaces the parts
of Oh My Zsh that were in use (history, auto_cd, key bindings, completion,
window title).

## Plugins

Loaded at the end of `.zshrc`, in this order: fzf-tab (cloned to
`~/.local/share/zsh/plugins/fzf-tab`), zsh-autosuggestions and
zsh-syntax-highlighting (Homebrew), then Starship.

## Startup speed

- `_cached_init` caches `starship init zsh` and `fzf --zsh` in `~/.cache/zsh`,
  regenerated when the binary is newer than the cache.
- The Starship cache bakes in the continuation prompt and sets `RPROMPT=''`
  (this config has no right_format), so each prompt runs starship once.
- compinit runs its security check once a day (`-C` otherwise) and the dump is
  compiled with zcompile.
- `~/.zprofile` (not tracked) holds a static copy of `brew shellenv`.

## ls

`ls`, `lsa`, `lt` and `lta` use eza with Omarchy's flags, but only when stdin
is a terminal and `CLAUDECODE` is unset. Claude Code copies these aliases into
its shell, where eza without a path waits on stdin and hangs.

## Secrets Management

`~/.config/zsh/.zshenv.local` contains machine-local secrets and is gitignored.
It is loaded at the top of `.zshrc`.

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
| `gfix` | `gcloud auth application-default login` | Refresh ADC auth |
| `cxl` | `codex -p lean --dangerously-bypass-approvals-and-sandbox` | Codex lean profile with approvals and sandbox disabled |

### Claude Code Aliases

| Alias | Command | Purpose |
|-------|---------|---------|
| `cl` | `claude` | Launch Claude Code |
| `cld` | `claude --dangerously-skip-permissions` | Skipped permissions, default model/effort |
| `cldr` | `claude --resume --dangerously-skip-permissions` | Resume with skipped permissions |
| `cldc` | `claude --continue --dangerously-skip-permissions` | Continue with skipped permissions |

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
- Claude Code no-flicker and tmux truecolor env flags are enabled
- `ENABLE_CLAUDEAI_MCP_SERVERS=false` keeps claude.ai MCP servers out of Claude Code

## Prompt Configuration

Starship, configured in `mac/.config/starship.toml` (linked to
`~/.config/starship.toml`): a machine logo pill, directory, Git branch and
status, then the prompt character. The chevron is green on the Mac and cyan
on omarchy.

The pill tells the machines apart at a glance:

| Machine | Logo | Pill | Logo colour |
|---|---|---|---|
| Mac | Apple, `U+E1BB` `U+E1BC` | `#3a3a3c` | `#FFFFFF` |
| omarchy | Arch, `U+E1B9` `U+E1BA` | `#163a4d` | `#1793D1` |

omarchy's `~/.config/starship.toml` is its own file, not linked to this repo,
so edit it there. Write the logos as `\uXXXX` escapes: Private Use Area
characters are easy to lose in copy and paste. Each logo is two characters,
the left and right halves of a logo built by
`mac/.config/herdr/fonts/build-fonts` (see `docs/herdr-sidebar.md`), so it
can be larger than one cell and still sit exactly centred in every terminal.
The pill has no spaces inside its round caps: the halves' own margins pad
the logo, so the pill is four cells wide. Alacritty and Herdr GPUI use the Herdr fonts directly, and Ghostty on both
machines maps `U+E1B9-U+E1BC` to them with `font-codepoint-map`, because IBM
Plex Sans TC on omarchy also covers that range. A terminal without the Herdr
fonts shows empty boxes.

## Syntax Highlighting

zsh-syntax-highlighting uses its plugin defaults; the tracked `.zshrc` does not
override semantic highlight colors.

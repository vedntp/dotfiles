# CLAUDE.md

## Overview

Plain zsh, no framework, with its own prompt in `prompt.zsh`. The tracked shell config is
`mac/.zshrc`, stowed to `~/.zshrc`. Oh My Zsh, Powerlevel10k and direnv were
removed on 2026-10-19; the "SHELL BASICS" block in `.zshrc` replaces the parts
of Oh My Zsh that were in use (history, auto_cd, key bindings, completion,
window title).

## Plugins

Loaded at the end of `.zshrc`, in this order: fzf-tab (cloned to
`~/.local/share/zsh/plugins/fzf-tab`), zsh-autosuggestions and
zsh-syntax-highlighting (Homebrew), then `prompt.zsh`.

## Startup speed

- `_cached_init` caches `fzf --zsh` in `~/.cache/zsh`, regenerated when the
  binary is newer than the cache.
- The prompt runs no external program outside a git repo (under 0.1 ms) and
  one `git status` inside one (about 10 to 15 ms). Starship took 20 to 30 ms.
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
| `menubar_restart` | `~/.local/bin/menubar_restart` | Unstick a menu bar ignoring clicks; logs to `~/Library/Logs/menubar_restart.log` |
| `cxl` | `codex -p lean --dangerously-bypass-approvals-and-sandbox` | Codex lean profile with approvals and sandbox disabled |

### Claude Code Aliases

| Alias | Command | Purpose |
|-------|---------|---------|
| `cl` | `cld` run from `~/scratch` (function, subshell) | Default launcher for chats with no project folder |
| `cld` | `claude --dangerously-skip-permissions` | Skipped permissions, default model/effort |
| `cldr` | `claude --resume --dangerously-skip-permissions` | Resume with skipped permissions |
| `cldc` | `claude --continue --dangerously-skip-permissions` | Continue with skipped permissions |
| `clf` | `cld` run from `~/.dotfiles` (function, subshell) | Skipped permissions in the dotfiles repo |

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

`mac/.config/zsh/prompt.zsh` (replaced Starship on 2026-11-02, so each folder
can have its own colour). A `precmd` hook rebuilds `PROMPT` each time:

- Logo pill, then one powerline segment per folder (`~` or `/` first), each a
  step lighter: `#141618 #1a1d1f #212427 #282c2f #303438` ("Ink"), text
  `#e8eaed`, current folder bold.
- Paths deeper than five parts keep the first and last three. In narrow panes
  middle folders fold into `…` until 30 columns stay free for typing.
- Git segment: green `#6fbf86` when clean, amber `#e0b25e` with changes. It
  shows ahead/behind, conflicts, changed and untracked counts from one
  `git status --porcelain=v2 --branch`. Repos are found by walking up for
  `.git` in zsh, so other folders run no process.
- Chevron uses the theme's ANSI green, red after a failed command, so it
  follows light and dark themes. The bar itself uses fixed hex colours and
  looks the same in Rex, Ghostty, Alacritty and light themes.
- `prompt_subst` is off: folder and branch names go into `PROMPT` verbatim,
  with `%` escaped.

The pill tells the machines apart at a glance:

| Machine | Logo | Pill | Logo colour |
|---|---|---|---|
| Mac | Apple, `U+E1BB` `U+E1BC` | `#3a3a3c` | `#FFFFFF` |
| omarchy | Arch, `U+E1B9` `U+E1BA` | `#163a4d` | `#1793D1` |

omarchy still uses Starship with its own `~/.config/starship.toml`, not
linked to this repo, so edit it there. Write the logos as `\uXXXX` escapes: Private Use Area
characters are easy to lose in copy and paste. Each logo is two characters,
the left and right halves of a logo built by
`mac/.config/herdr/fonts/build-fonts` (see `docs/herdr-sidebar.md`), so it
can be larger than one cell and still sit exactly centred in every terminal.
The pill has no spaces inside its round caps: the halves' own margins pad
the logo, so the pill is four cells wide. Alacritty and Herdr GPUI use the Herdr fonts directly, and Ghostty on both
machines maps `U+E1B9-U+E1BC` to them with `font-codepoint-map`, because IBM
Plex Sans TC on omarchy also covers that range. A terminal without the Herdr
fonts shows empty boxes.

App terminals built on xterm.js (Claude, ChatGPT and T3 Code desktop apps,
VS Code) can't map codepoints to a font, and macOS font fallback never
reaches the Herdr fonts for Private Use Area characters. `.zshrc` spots them
by the shell's parent process name and exports `PROMPT_LOGO=' \uf8ff '`.
That is Apple's own logo codepoint, which the macOS system fonts cover, so it
renders anywhere. `prompt.zsh` uses `PROMPT_LOGO` when set and the Herdr pair
otherwise, so other terminals are unchanged.

omarchy does the same with the Arch logo (`U+F303`, from the Nerd Font). `.zshrc`
also exports `PLAIN_PROMPT_LOGO=1`, `~/.ssh/config` sends it with `SendEnv`,
`/etc/ssh/sshd_config.d/30-plain-prompt-logo.conf` on omarchy accepts it, and
omarchy's `~/.zshrc` turns it into its own `STARSHIP_LOGO`. A shared SSH
connection that was opened before the variable was accepted won't carry it.

## Syntax Highlighting

zsh-syntax-highlighting uses its plugin defaults; the tracked `.zshrc` does not
override semantic highlight colors.

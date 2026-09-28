# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
this repository.

## Overview

User dotfiles (`~/.dotfiles`) are managed with GNU Stow. This repo is now a
macOS-focused setup with a single active Stow package: `mac/`.

The workflow is Vim-centric and keyboard-driven. Terminal tools use portable
application defaults instead of a repository-wide custom palette.

## Common Commands

```bash
# Deploy configs
cd ~/.dotfiles && stow mac

# Validate configs
ghostty +validate-config --config-file ~/.config/ghostty/config
aerospace reload-config

# Reload configs
tmux source-file ~/.config/tmux/tmux.conf
~/.config/emacs/bin/doom sync              # after init.el/packages.el changes

# Neovim plugins
:Lazy                                       # open plugin manager UI
```

## Directory Structure

```text
~/.dotfiles/
|-- mac/                    # Active Stow package
|   |-- .zshrc              # Shell config
|   |-- .p10k.zsh           # Powerlevel10k prompt
|   |-- .gitconfig          # Git config
|   |-- .fzf.zsh            # FZF shell integration
|   |-- .local/bin/         # Helper scripts
|   |-- Library/LaunchAgents/ # Per-user background services
|   `-- .config/
|       |-- zsh/
|       |-- nvim/
|       |-- tmux/
|       |-- doom/
|       |-- aerospace/
|       |-- ghostty/
|       |-- alacritty/
|       |-- linearmouse/
|       |-- git/
|       |-- ranger/
|       |-- bat/
|       |-- btop/
|       `-- neofetch/
|-- archive/linux/          # Inactive Linux config kept for reference
`-- server/                 # Active Ubuntu terminal package
```

## App-Specific Docs

Each app has its own docs with keybindings, settings, and gotchas:

- `mac/.config/zsh/CLAUDE.md` - Shell, plugins, aliases, Claude Code setup
- `mac/.config/nvim/CLAUDE.md` - Neovim keybindings, lazy.nvim plugins
- `mac/.config/tmux/CLAUDE.md` - tmux bindings, TPM plugins, statusline notes
- `mac/.config/doom/CLAUDE.md` - Literate config, GTD setup, gptel
- `mac/.config/aerospace/CLAUDE.md` - Workspace assignments, app matching rules
- `mac/.config/aerospace/AGENTS.md` - Agent notes for AeroSpace edits
- `mac/.config/ghostty/CLAUDE.md` - Current native/minimal Ghostty setup
- `mac/.config/ghostty/AGENTS.md` - Agent notes for Ghostty edits
- `docs/airpods-banner-dismiss.md` - AirPods system-banner investigation
- `docs/web-apps.md` - Web app (PWA) preferences, inventory, `webapp-icon`

## Key Architecture

**Active package**: `mac/` is the only active Stow package. The old Linux package
is archived under `archive/linux/` and is not part of the deployment flow.

**Terminal stack**: Ghostty is currently minimal and stock-leaning. It uses
native Ghostty tabs, splits, scrollback, and Cmd shortcuts. The older
Cmd-to-Meta tmux integration is archived in Ghostty docs, while tmux still has
Meta bindings available for terminals that send Meta.

**Secrets**: API keys and machine-local config live in ignored `.local` files:

- `~/.config/zsh/.zshenv.local`
- `~/.config/zsh/.zshrc.local`
- `~/.config/git/config.local`
- app-specific `config.local` files where present

**Stow symlinks**: Stow creates symlinks from `~/` and `~/.config/` into
`mac/`, including:

- `~/.zshrc` -> `mac/.zshrc`
- `~/.p10k.zsh` -> `mac/.p10k.zsh`
- `~/.gitconfig` -> `mac/.gitconfig`
- `~/.fzf.zsh` -> `mac/.fzf.zsh`
- `~/.config/nvim/` -> `mac/.config/nvim/`
- `~/.config/tmux/` -> `mac/.config/tmux/`
- `~/.config/doom/` -> `mac/.config/doom/`
- `~/.config/git/` -> `mac/.config/git/`

**Claude Code**: `claude` is the default Claude Code command. The tracked
`.zshrc` defines aliases such as `cl`, `cld`, `cldr`, and `cldc`. If `glm` is available, it comes from local shell config or another
installed command, not from the tracked `.zshrc`.

**AirPods banners**: Suppression is still under investigation. The old
unified-log watcher was removed because its events arrive after Control Center
has already created the Essential-urgency banner. Keep findings in
`docs/airpods-banner-dismiss.md`, preserve automatic switching, and require the
user to confirm both routing directions before calling a candidate solved.

## Color defaults

Ghostty and Alacritty use their terminal palettes. macOS Powerlevel10k uses a
compact one-line Lean prompt, while the server keeps the upstream rainbow
layout. tmux inherits terminal colors, Ranger uses its bundled default, Bat
uses `ansi`, Neovim uses Kanagawa Wave, and Doom Org faces inherit Doom One.

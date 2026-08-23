<h1 align="center">~/.dotfiles</h1>

<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&size=18&duration=3000&pause=1000&center=true&vCenter=true&width=435&lines=vim+enthusiast;keyboard+driven+workflow;portable+terminal+colors;macOS+daily+driver" alt="Typing SVG" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-Sequoia-000000?logo=apple&logoColor=white" alt="macOS">
  <img src="https://img.shields.io/badge/Neovim-57A143?logo=neovim&logoColor=white" alt="Neovim">
  <img src="https://img.shields.io/badge/Doom%20Emacs-7F5AB6?logo=gnuemacs&logoColor=white" alt="Doom Emacs">
  <img src="https://img.shields.io/badge/Zsh-F15A24?logo=zsh&logoColor=white" alt="Zsh">
  <img src="https://img.shields.io/badge/tmux-1BB91F?logo=tmux&logoColor=white" alt="tmux">
  <img src="https://img.shields.io/badge/Ghostty-161616?logo=ghost&logoColor=white" alt="Ghostty">
  <br>
  <img src="https://visitor-badge.laobi.icu/badge?page_id=vedntp.dotfiles" alt="Visitors">
</p>

---

## Quick Start

```bash
# Clone
git clone git@github.com:vedntp/dotfiles.git ~/.dotfiles

# Deploy
cd ~/.dotfiles
stow mac

# Ubuntu server terminal
scripts/provision-server-terminal.sh
```

## What's Inside

| Tool | Path | Purpose | Docs |
|------|------|---------|------|
| [aerospace](mac/.config/aerospace/) | `mac` | Tiling window manager | [CLAUDE.md](mac/.config/aerospace/CLAUDE.md) |
| [nvim](mac/.config/nvim/) | `mac` | Neovim with lazy.nvim | [CLAUDE.md](mac/.config/nvim/CLAUDE.md) |
| [doom](mac/.config/doom/) | `mac` | Doom Emacs, GTD, org-roam, gptel | [CLAUDE.md](mac/.config/doom/CLAUDE.md) |
| [tmux](mac/.config/tmux/) | `mac` | Terminal multiplexer | [CLAUDE.md](mac/.config/tmux/CLAUDE.md) |
| [zsh](mac/.config/zsh/) | `mac` | Shell, Oh My Zsh, p10k | [CLAUDE.md](mac/.config/zsh/CLAUDE.md) |
| [ghostty](mac/.config/ghostty/) | `mac` | Terminal emulator | [CLAUDE.md](mac/.config/ghostty/CLAUDE.md) |
| [herdr](mac/.config/herdr/) | `mac` | Agent terminal workspace manager | - |
| [ranger](mac/.config/ranger/) | `mac` | File manager | - |
| [bat](mac/.config/bat/) | `mac` | Cat clone with syntax highlighting | - |
| [btop](mac/.config/btop/) | `mac` | System monitor | - |
| [server terminal](docs/server-terminal.md) | `server` | Ubuntu zsh, P10K, Neovim, Ranger, bat, btop, tmux | [setup](docs/server-terminal.md) |

## Structure

```text
~/.dotfiles/
|-- mac/                    # Active Stow package
|   |-- .zshrc              # Shell config
|   |-- .p10k.zsh           # Powerlevel10k prompt
|   |-- .gitconfig          # Git config
|   |-- .fzf.zsh            # FZF shell integration
|   |-- .taskrc             # Taskwarrior config
|   |-- .local/bin/         # Helper scripts and background watchers
|   |-- Library/LaunchAgents/ # Per-user background services
|   `-- .config/
|       |-- aerospace/      # Tiling window manager
|       |-- ghostty/        # Terminal emulator
|       |-- herdr/          # Agent terminal workspace manager
|       |-- alacritty/      # Alternate terminal config
|       |-- linearmouse/    # Mouse settings
|       |-- nvim/           # Neovim + lazy.nvim plugins
|       |-- tmux/           # tmux + TPM
|       |-- doom/           # Doom Emacs
|       |-- zsh/            # zsh docs and local overrides
|       |-- git/            # Git ignore and local credential helper
|       |-- ranger/         # File manager
|       |-- bat/            # Syntax highlighting
|       |-- btop/           # System monitor
|       `-- neofetch/       # System info
|-- archive/
|   `-- linux/              # Inactive Linux package kept for reference
|-- server/                 # Ubuntu server terminal package
|-- scripts/
|   `-- provision-server-terminal.sh
|-- docs/
|-- CLAUDE.md
|-- AGENTS.md
`-- README.md
```

## Key Features

- **Two focused packages** - `mac` for the Mac and `server` for Ubuntu servers
- **Vim-centric** - Evil mode in Emacs, vim keybinds everywhere
- **Keyboard-driven** - AeroSpace WM, tmux, minimal mouse usage
- **Terminal workflow** - Ghostty is native/minimal; tmux remains available for multiplexing
- **Spokenly dictation** - MacBook and Ducky use Spokenly's direct Right Option shortcut; the MX Master thumb button toggles Spokenly through its helper app
- **Three Finger Switcher** - One local recognizer arbitrates three-finger input: taps toggle Spokenly after release, right swipes open the app switcher with two-finger scrubbing, and left swipes route one context-aware line-clear shortcut

## Notes

- [Spokenly transcription profile](docs/transcription/spokenly/README.md)
- [Custom Logitech, BetterTouchTool, and transcription shortcut reference](docs/shortcut-reference.md)
- [MX Master 3S, Logitech Options+, and Spokenly setup](docs/logitech-options-spokenly.md)
- [BetterTouchTool gesture setup](docs/btt/README.md)
- [Native Three Finger Switcher](docs/three-finger-switcher.md)
- [Ducky One 2 macOS setup](docs/ducky-one-2-setup.md)
- [AirPods smart-routing banner investigation](docs/airpods-banner-dismiss.md)

## Portable color defaults

Terminal emulators use their default palettes. macOS Powerlevel10k uses a
compact one-line Lean prompt, while the server keeps the upstream rainbow
layout. tmux inherits terminal colors, Ranger uses its bundled default, Bat
uses `ansi`, Neovim uses Kanagawa Wave, and Doom Emacs inherits Doom One.

---

<p align="center">
  <img src="https://quotes-github-readme.vercel.app/api?type=horizontal&theme=dark&quote=Talk%20is%20cheap.%20Show%20me%20the%20code.&author=Linus%20Torvalds" alt="Quote" />
</p>

<p align="center">
  <sub>Managed with GNU Stow</sub>
</p>

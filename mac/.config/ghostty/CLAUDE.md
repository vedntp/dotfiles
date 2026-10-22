# CLAUDE.md

Ghostty terminal emulator configuration for macOS.

**Current state (2026-08-19):** a compact native Ghostty configuration using
the Nightfox Carbonfox theme. The previous tmux-centric setup (Cmd→Meta routing +
auto-launch tmux) is archived. See `docs/CHANGELOG.md` for the full before/after
and restore instructions; the old config is at `docs/config.original-2026-06-16.bak`.

## Validation

```bash
ghostty +validate-config --config-file ~/.config/ghostty/config
ghostty +show-config  # Show effective config vs defaults
```

## Current Settings

The live config is intentionally compact:

- `theme = Carbonfox`
- `background-opacity = 1`
- `background-blur` is disabled
- `font-family = JetBrainsMono Nerd Font Mono`
- `font-codepoint-map = U+E1B9-U+E1BC=JetBrains Mono Herdr XL` for the
  Starship prompt logos (see `mac/.config/zsh/CLAUDE.md`)
- `font-size = 18`
- `macos-titlebar-style = transparent`
- `window-padding-x = 12`, `window-padding-y = 10`

The config file is the source of truth; do not trust exact values written here.

Everything else runs at Ghostty defaults, including:
- **Font rendering:** default weight and antialiasing; `font-thicken` remains
  `false`.
- **Clipboard:** stock copy/paste works out of the box. Re-add
  `clipboard-read = allow` only to silence OSC52 read prompts, or
  `copy-on-select = clipboard` to auto-copy mouse selections.
- **Keybinds:** native Ghostty Cmd shortcuts are active (tabs, splits, search,
  font size, select-all, command palette `cmd+shift+p`, etc.).
- **tmux:** not auto-launched. An existing session keeps running in the background;
  reattach with `tmux attach -t '⭐ main'`.

## Archived: previous tmux-centric setup

The setup below is **not active** — it is restored by copying
`docs/config.original-2026-06-16.bak` back to `config`. Kept here for reference.

### Cmd-to-Meta Keybind Routing

Ghostty intercepted Cmd keys and sent them as Meta (Escape prefix `\x1b`) sequences
to tmux, enabling Mac-native shortcuts that drove the multiplexer:

| Ghostty Cmd Key | Sends to tmux | tmux Action |
|-----------------|---------------|-------------|
| `Cmd+d` | `M-d` | Split pane horizontal |
| `Cmd+Shift+d` | `M-D` | Split pane vertical |
| `Cmd+t` | `M-t` | New window |
| `Cmd+Shift+r` | `M-R` | Reload tmux config |
| `Cmd+w` | `M-w` | Close pane |
| `Cmd+Shift+w` | `M-W` | Close window |
| `Cmd+1-9` | `M-1-9` | Switch to window 1-9 |
| `Cmd+[` / `Cmd+]` | `M-[` / `M-]` | Previous/next window |
| `Cmd+f` | `M-f` | tmux search/find |
| `Cmd+a` | `M-a` | Enter copy mode |
| `Cmd+z` | `M-z` | Zoom pane |
| `Cmd+e` | `M-e` | Flat picker (windows) |
| `Cmd+Shift+e` | `M-E` | Session picker |
| `Cmd+s` | `M-s` | Choose session |
| `Cmd+Shift+s` | `M-S` | Save session (resurrect) |
| `Cmd+t` | `M-t` | New window |
| `Cmd+Shift+t` | `M-T` | Restore session (resurrect) |
| `Cmd+n` | `M-n` | New session (with name) |
| `Cmd+o` | `M-o` | Sessionx picker |
| `Ctrl+Tab` | `C-Right` | Next window |
| `Ctrl+Shift+Tab` | `C-Left` | Previous window |

The escape sequence `\x1b` is the Meta prefix. For example, `\x1bd` = Escape+d = Meta-d.

### tmux Integration

- Ghostty auto-launched tmux session `⭐ main` on startup via
  `command = /opt/homebrew/bin/tmux new-session -A -s '⭐ main'`
- All window/pane management happened in tmux, not Ghostty
- Changes to keybinds had to coordinate with `~/.config/tmux/tmux.conf` Meta bindings
- Scrolling inside tmux is line-granular copy-mode, never as smooth as native
  scrollback; step size tuned via WheelUpPane/WheelDownPane in `~/.config/tmux/tmux.conf`
- Restart Ghostty to apply keybind changes (no hot reload)

## Config Syntax

```
key = value
keybind = modifier+key=action
```

One setting per line, `#` for comments. Keep settings grouped by function.

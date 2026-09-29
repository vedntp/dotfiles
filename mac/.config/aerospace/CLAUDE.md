# CLAUDE.md

AeroSpace tiling window manager config for macOS. i3-like behavior with vim-style keybindings.

## Commands

```bash
aerospace reload-config          # Apply changes (or alt-shift-; then esc)
aerospace list-windows --all     # Debug window assignments
aerospace list-workspaces        # See all workspaces
```

The daily build is the `pszypowicz/tap/aerospace-bsp` fork installed as
`/Applications/AeroSpace.app`, currently `0.21.3-bsp.2`. AeroSpace manages its
own login item through `start-at-login = true`, and the global fork-only
`enable-normalization-bsp-shape = true` setting makes BSP survive restarts and
apply to every workspace.

The config uses `config-version = 2`. `persistent-workspaces` explicitly
preserves the v1 behavior for all currently bound workspace keys.

## Keybindings

**Navigation** (alt + vim keys):
- `alt-hjkl` - Focus window left/down/up/right
- `alt-shift-hjkl` - Move window left/down/up/right

**Workspaces**:
- `alt-[1-0]` - Switch to workspace 1-10
- `alt-[a-z]` - Switch to letter workspace (except r reserved)
- `alt-shift-[key]` - Move window to that workspace
- `alt-tab` / `alt-shift-tab` - Herdr next / previous agent when Herdr is active
- `alt-backtick` - Jump to next empty workspace
- `cmd-shift-backtick` - Move window to first empty workspace on the other monitor

**Layout**:
- `alt-/` - Toggle tiles horizontal/vertical
- `alt-,` - Toggle accordion layout
- `alt--` / `alt-=` - Resize window

**Service mode** (`alt-shift-;`):
- `esc` - Reload config and exit
- `r` - Reset/flatten workspace layout
- `f` - Toggle floating/tiling
- `backspace` - Close all windows but current

## Monitor Setup

- Primary letter workspaces prefer `LG HDR 4K`, falling back to macOS `main`.
- Workspace 1 plus workspaces 2-10, E, F, G, M, O, Y, Z prefer the built-in display, falling back to `secondary` then `main`.
- AeroSpace `main` follows macOS System Settings -> Displays -> Use as Main Display; the config targets the LG by name so the main workspace group does not depend on that OS setting.

## App Assignments

| Workspace | Apps |
|-----------|------|
| 1 | Persistent support workspace; Alacritty, cmux, and Warp tile where opened |
| 2 | Calendar |
| 3 | Things, Linear |
| 4-6 | TradingView, IB Gateway, TWS |
| 8 | Discord, Telegram, WhatsApp |
| 10 | Spotify, YouTube Music |
| A | Excel, Word, sioyek |
| B | Arc, Firefox, Brave, Helium |
| C | ChatGPT, Chrome |
| D | Emacs |
| E | Finder (floating) |
| F | Drafts |
| G | Gemini, Grok |
| M | Gmail |
| N | Safari, Notion |
| O | Books (floating), Obsidian |
| P | VS Code |
| S | Slack |
| V | Claude |
| X | Amp, Conductor |
| Y | YouTube |
| Z | Day One |

## Floating Apps

mpv floats and follows the focused workspace, including across monitors, through
`~/.local/bin/aerospace-pip-guardian`. All managed `io.mpv` windows follow.
`~/.config/mpv/mpv.conf` sets `ontop=yes` to keep video above ordinary windows.
Restart existing mpv instances to load this setting. Workspace following can
briefly reposition the window; it is a helper, not native sticky-window support.
See [mpv workspace following](../../../docs/mpv-workspace-following.md) for
configuration details, verification, limitations, and disable instructions.

These apps launch floating instead of tiled: Ghostty, Finder, Books, mpv, CodexBar, Codex, CleanShot X, System Settings, and Raycast. Ghostty stays floating because macOS native tabs are exposed to AeroSpace as separate windows and can trigger unwanted BSP retiling. Alacritty, cmux, and Warp use tiled layout where they open so separate terminal windows can participate in BSP. Native tabs remain inside the terminal application.

CleanShot X, System Settings, Raycast, CoreServices UI Agent system prompts, and
Problem Reporter crash dialogs are floated in place so utility windows stay in
the workspace where they were invoked instead of hitting the empty-workspace
catch-all.

The final empty-workspace catch-all applies only to tiled windows. Windows
AeroSpace recognizes as dialogs are floating by default, so they remain beside
the application that opened them instead of being moved to another workspace.

PiP handling is centralized in `~/.local/bin/aerospace-pip-guardian`. Its automatic workspace-change mode moves AeroSpace-managed Helium `Picture-in-picture` windows to the focused workspace and unhides hidden Brave-owned YouTube PWA PiP windows. Press `ctrl-alt-p` to run the stronger recovery mode, which also recreates stale Helium native PiP windows by toggling the Google PiP extension.

The main ChatGPT window stays assigned to workspace `C`. AeroSpace
`0.21.0-Beta` and later recognizes the always-on-top `com.openai.codex` Pet as
an unmanaged popup, so it remains stable across workspace changes without a
sticky-window rule or helper.

## ChatGPT Pet Maintenance

- Keep AeroSpace at `0.21.0-Beta` or later for the built-in Codex Pet popup
  detection.
- After updating ChatGPT, confirm the Pet remains visible and stable while
  changing workspaces. If flickering returns, use `aerospace debug-windows` to
  verify that the Pet is classified as a popup rather than a managed window.

## Gotchas

- **BSP config is fork-only**: Vanilla AeroSpace does not understand
  `enable-normalization-bsp-shape`. Remove that key before launching vanilla.
- **BSP updates follow the fork**: The version is anchored to an upstream
  release, but the fork maintainer publishes its own `bsp.N` builds. Use
  `brew upgrade --cask aerospace-bsp` to update.
- **App matching**: Uses `app-name-regex-substring` (partial match) or `app-id` for specific bundle IDs
- **Ghostty stays floating**: macOS native tabs can appear to AeroSpace as
  separate windows and trigger unwanted BSP retiling, so Ghostty uses
  `layout floating`. Alacritty, cmux, and Warp use `layout tiling` where they
  open. Native tabs remain inside the terminal application.
- **YouTube PWA PiP can vanish**: The `YouTube` app is a Brave app-mode wrapper (`com.brave.Browser.app...`), but its PiP window is owned by the parent `Brave Browser` process. If PiP disappears, check whether `Brave Browser` is hidden while `YouTube` is visible. `aerospace-pip-guardian auto` usually recovers this; use `ctrl-alt-p` for manual recovery.
- **Zero gaps**: `[gaps]` section has all values at 0
- **Mouse follows monitor**: When focus changes monitors, mouse moves to center
- **No generic sticky windows**: Feature not yet supported (issue #2). The
  Codex Pet does not require it because AeroSpace recognizes the Pet as an
  unmanaged popup.
- **Reserved bindings**: `alt-r` is commented out

## Adding New App Assignment

```toml
[[on-window-detected]]
if.app-name-regex-substring = 'AppName'
run = 'move-node-to-workspace X'

# Or for floating:
run = ['layout floating', 'move-node-to-workspace X']

# Or by bundle ID (more precise):
if.app-id = 'com.company.appname'
```

Find app bundle ID: `osascript -e 'id of app "AppName"'`

## Switching Between BSP And Vanilla

Return to vanilla:

1. Remove `enable-normalization-bsp-shape = true` from `aerospace.toml`.
2. Run `brew uninstall --cask aerospace-bsp`.
3. Run `brew install --cask nikitabobko/tap/aerospace`.
4. Run `open -a AeroSpace`.

Switch back to BSP:

1. Restore `enable-normalization-bsp-shape = true`.
2. Run `brew uninstall --cask aerospace`.
3. Run `brew install --cask pszypowicz/tap/aerospace-bsp`.
4. Run `open -a AeroSpace`.

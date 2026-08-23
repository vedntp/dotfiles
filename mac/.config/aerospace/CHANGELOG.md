# Aerospace Configuration Changelog

## 2026-08-21
- Reassigned Option+Tab and Option+Shift+Tab from AeroSpace workspace cycling
  and monitor movement to Herdr next-agent and previous-agent navigation.

## 2026-08-17
- Upgraded the official AeroSpace app from `0.20.3-Beta` to `0.21.3-Beta`.
- Removed the custom PR #2083 `AeroSpace Sticky.app`, its LaunchAgent, the
  sticky Pet helper, and the custom client selector.
- Restored AeroSpace's supported `start-at-login` registration and updated the
  F8 process toggle to launch only `/Applications/AeroSpace.app`.
- Removed the ChatGPT sticky command. AeroSpace `0.21.0-Beta` and later treats
  the always-on-top Codex Pet as an unmanaged popup, preventing workspace
  flicker without generic sticky-window support.
- Fixed Helium PiP following and stale-window recovery after its window title
  changed capitalization from `Picture-in-picture` to `Picture-in-Picture`.

## 2026-08-03
- Migrated to `config-version = 2` and explicitly listed persistent workspaces
  to preserve the former v1 binding-inferred lifecycle.
- Removed the retired Comet assignment.
- Moved Day One to workspace `Z`, which is already designated for
  journal/knowledge use.
- Moved Slack (`com.tinyspeck.slackmacgap`) from workspace 8 to workspace S.

## 2026-07-25
- Added Linear (`com.linear`) to workspace 3 by default.

## 2026-07-23
- Added Slack (`com.tinyspeck.slackmacgap`) to workspace 8 by default.
- Restricted the empty-workspace catch-all to tiled windows so floating
  dialogs recognized by AeroSpace remain in the workspace where they appear.

## 2026-07-21
- Added the Grok Brave web app
  (`com.brave.Browser.app.ggjocahimgaohmigbfhghnlfcnjemagj`) to workspace G.

## 2026-07-14
- Added floating-in-place exclusions for macOS CoreServices UI Agent
  (`com.apple.coreservices.uiagent`) copy/install conflict prompts and Problem
  Reporter (`com.apple.ProblemReporter`) crash dialogs so transient system
  messages bypass the empty-workspace catch-all.

## 2026-07-13
- Added a Wispr Flow (`com.electron.wispr-flow.accessibility-mac-app`)
  floating-in-place exclusion so its windows bypass the empty-workspace
  catch-all.
- Removed the retired workspace-2 voice utility rule and its documentation.

## 2026-07-10
- Added a CodexBar floating-in-place rule so its windows bypass the empty-workspace catch-all.
- Added a local `aerospace` client selector and placed `~/.local/bin` first in
  AeroSpace's exec `PATH`. The sticky and released builds use different server
  sockets, so shell-based bindings and helpers must use the matching client.
- Added a separate local `AeroSpace Sticky.app` built from upstream PR #2083.
  The released `/Applications/AeroSpace.app` remains installed for rollback.
- Disabled AeroSpace's built-in login registration and added
  `com.vp.aerospace-sticky.plist` so the sticky build launches at login.
- Added `aerospace-sticky-pet`, invoked from the ChatGPT detection rule, to
  apply `layout sticky` only when the custom snapshot server is active. The
  helper safely does nothing when the released AeroSpace server is running.
- Updated the F8 process toggle to prefer `AeroSpace Sticky.app` when starting
  AeroSpace.

## 2026-07-08
- Moved workspace G from the LG primary group to the built-in/secondary display group.
- Added a Raycast float-in-place exception so launcher windows stay in the invoking workspace instead of hitting the empty-workspace catch-all.

## 2026-07-07
- Changed Codex from being forced to workspace C and floating to floating only, so new Codex windows are no longer moved to workspace C but still launch floating.
- Changed monitor assignments to make `LG HDR 4K` the explicit primary workspace target, with built-in-display support workspaces and fallbacks for single-monitor sessions.
- Added `cmd-shift-backtick` via `~/.local/bin/aerospace-move-to-empty-workspace-other-monitor` to move the focused window to the first empty workspace on the other monitor.
- Added a CleanShot X float-in-place exception so screenshot annotation windows stay in the invoking workspace instead of hitting the empty-workspace catch-all.
- Added a System Settings float-in-place exception so settings windows stay in the invoking workspace instead of hitting the empty-workspace catch-all.
- Moved workspace 1 from the LG primary group to the built-in/secondary display group.
- Moved workspace Y from the LG primary group to the built-in/secondary display group.
- Moved workspace O from the LG primary group to the built-in/secondary display group.

## 2026-07-04
- Added `aerospace-pip-guardian` with separate PiP branches instead of one-off fixes:
  - `auto` runs from `exec-on-workspace-change`, moves managed Helium PiP windows to the focused workspace, and unhides hidden Brave-owned YouTube PWA PiP windows.
  - `recover` is bound to `ctrl-alt-p` and additionally recreates stale Helium native PiP windows by toggling Helium's Google Picture-in-Picture extension.

## 2026-07-01
- Documented YouTube Brave app-mode PiP recovery notes. The YouTube PWA (`com.brave.Browser.app.agimnkijcaahngcdmfeangaknmldooml`) can create PiP under the hidden parent Brave process (`com.brave.Browser`), leaving the PiP present but offscreen. Runtime recovery is to activate Brave Browser; no persistent AeroSpace config change was kept.

## 2026-06-29
- Added Alacritty (`org.alacritty`) to workspace 1 with the same floating treatment as Ghostty: `run = ['layout floating', 'move-node-to-workspace 1']`.

## 2026-06-08
- Restored Ghostty floating layout: changed its rule from `run = 'move-node-to-workspace 1'` to `run = ['layout floating', 'move-node-to-workspace 1']`. The floating layout had been dropped despite the 2026-01-03 change and the CLAUDE.md "Ghostty is floating" note, so the config now matches the docs again.
- Added cmux terminal (`com.cmuxterm.app`) with the same treatment as Ghostty: `run = ['layout floating', 'move-node-to-workspace 1']`. Previously it had no rule, so the catch-all moved it to the first empty workspace.
- Added Warp terminal (`dev.warp.Warp-Stable`) with the same treatment: `run = ['layout floating', 'move-node-to-workspace 1']`. Re-adds a Warp assignment that was removed on 2025-08-20, this time floating.
- Added Helium browser (`net.imput.helium`) to workspace B, matching the Brave rule (`run = 'move-node-to-workspace B'`, tiled, no floating).

## 2026-05-28
- Moved Day One from workspace D to workspace S (shared with Comet), freeing D for Emacs only

## 2026-05-07
- Added menu bar / popover exclusion rules above the catch-all so their windows are not moved to an empty workspace:
  - Cloudflare WARP (`com.cloudflare.1dot1dot1dot1.macos`)
  - 1Password (`com.1password.1password`)
  - macOS LocalAuthentication agent (`com.apple.LocalAuthentication.UIAgent`), used by the 1Password Quick Access launcher (Cmd+Shift+Space) and Touch ID / system password prompts
- Each exclusion uses `run = ['layout floating']` as a benign no-op that matches and stops further callbacks (an empty `run = []` did not reliably block the catch-all).
- Add new offenders the same way: discover the bundle id via `aerospace list-apps` (or `aerospace list-windows --all` while the popover is visible) and insert a block above the catch-all.

## 2026-05-05
- Added catch-all `on-window-detected` rule at the end of the rule list: any app without an explicit workspace assignment is moved to the first empty workspace on the focused monitor (uses the same shell pattern as `alt-shift-backtick`). Apps with specific rules above are unaffected because matching rules set `check-further-callbacks = false` by default. The catch-all must remain the last `[[on-window-detected]]` block in the file.

## 2026-01-08
- Changed `alt-tab` from `workspace-back-and-forth` to cycle through non-empty workspaces on the focused monitor

## 2026-01-03
- Set Ghostty windows to floating to avoid tab-induced tiling splits

## 2025-09-20
- Fixed workspace 0/10 keybinding inconsistency: unified alt+0 and alt+shift+0 to workspace 10
- Reorganized workspace 2 around Calendar and removed the Terminal assignment
- Assigned trading apps: TradingView→ws4, IB Gateway→ws5, Trader Workstation→ws6
- Added music streaming apps to workspace 10: Spotify and YouTube Music
- Fixed YouTube Music rule precedence to prevent assignment to workspace Y

## 2025-08-31
- Added Books app configuration: auto-assign to workspace O with floating layout

## 2025-08-20
- Removed default workspace assignments for Warp and Ghostty terminals
- Removed workspace 1 monitor assignment to secondary

## 2025-08-14
- Enabled workspace E for Finder, reorganized terminals (Warp→1, Terminal/Ghostty→2)
- Removed mpv workspace assignments due to file association conflicts

## 2025-08-10
- Added `alt-esc`: Cycle through windows in current workspace with wrap-around

## 2025-08-07
- Added `ctrl-alt-n`: Launch Safari in private browsing mode
- Changed Safari default workspace from S to N

## 2025-08-06

### App Workspace Assignments
- Added comprehensive app-to-workspace assignments using `on-window-detected` for automatic window placement
- Configured workspace-to-monitor assignments for dual-monitor setup

### Custom Keybindings
- Added `alt-shift-backtick`: Move window to next available empty workspace

## 2025-07-31

### Customizations from Default Config

**Window Gaps**
- Removed all window gaps (set to 0) for a more compact tiling layout without spacing between windows

**Workspace Bindings**
- Extended alphabet workspace support to include: A, B, C, D, F, G, I, M, N, O, P, Q, R, S, T, U, V, W, Y, Z
- Disabled workspace E and X bindings (commented out)

**Custom Keybindings**
- `alt-backtick`: Switch to first empty workspace on current monitor
- `alt-enter`: Launch terminal application

**Service Mode Additions**
- Added volume controls in service mode: `up/down` for volume adjustment, `shift-down` for mute

**Configuration Location**
- Moved config from `~/.aerospace.toml` to `~/.config/aerospace/aerospace.toml` following XDG Base Directory specification

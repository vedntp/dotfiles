# mpv: always on top and workspace following

Configured on 2026-09-29.

## Behavior

All AeroSpace-managed mpv windows float and follow the focused workspace. For
example, switching from `1` to `B` moves mpv to `B`. If the destination workspace
is on another monitor, mpv follows it there. mpv keeps the video above ordinary
windows using its own always-on-top setting.

There is no fixed mpv workspace assignment. Older references to workspace `E`
are obsolete. This applies to all managed mpv windows, not just one player.

## Configuration

- [AeroSpace config](../mac/.config/aerospace/aerospace.toml) floats newly
  detected mpv windows and runs `aerospace-pip-guardian auto` on workspace changes.
- [PiP guardian](../mac/.local/bin/aerospace-pip-guardian) matches the `io.mpv`
  bundle ID, applies floating layout, and moves each window to the destination
  workspace if needed. It does not explicitly activate mpv. Existing Helium and
  Brave PiP handling remains in the same helper.
- [mpv config](../mac/.config/mpv/mpv.conf) sets `ontop=yes`. GNU Stow deploys it
  to `~/.config/mpv/mpv.conf`.

The helper is also deployed through Stow, so tracked helper edits take effect
on the next invocation. After AeroSpace config edits, run
`aerospace reload-config`. New mpv processes load the mpv configuration; for an
already running player, use **View > Toggle Float on Top** if it is not already
enabled, or restart the player.

## Verification

On 2026-09-29:

- Reloaded AeroSpace successfully and checked the helper's Zsh syntax.
- Tested the existing mpv window through `1 → B → 1`; AeroSpace reported the
  destination workspace and `floating` layout at each step.
- Confirmed that the existing player had macOS window layer `3`, the floating
  window level.
- Started a temporary headless mpv instance and queried its `ontop` property
  through IPC, confirming that the deployed configuration loaded `true`.

For a manual check, play a video, switch between `1` and `B`, and focus another
ordinary window. The video should follow and remain above it.

## Limitations

This is a workspace-change workaround, not native sticky-window support.
Switching can briefly reposition the player. It follows the active workspace
rather than staying on a fixed monitor. Visibility above native fullscreen apps,
system overlays, or across macOS Spaces was not verified.

mpv's `on-all-workspaces=yes` targets native macOS Spaces and is not enabled here.
The AeroSpace helper provides workspace following.

## Turn it off

- To stop workspace following, remove only the `io.mpv)` branch from
  `follow_managed_pip` in the PiP guardian. Keep the helper callback for browser
  PiP support. mpv will still float where it opens.
- To stop always-on-top, change `ontop=yes` to `ontop=no` in the tracked mpv
  config and restart mpv. For the current player, the View menu toggle changes
  the setting immediately.

These settings are independent, so either behavior can be disabled separately.

# AeroSpace: Helium Picture-in-Picture following

Configured on 2026-10-15. Verified working by the user the same day.

## Problem

AeroSpace has no sticky windows. When you switch workspaces, every window on the
old workspace is hidden, including a Picture-in-Picture (PiP) window. On top of
that, the Helium rule (`layout tiling`, `move-node-to-workspace B`) matches the
PiP window too, since it shares the `net.imput.helium` bundle ID. That tiled PiP
into workspace `B` like a normal browser window.

## Behavior

- Helium PiP windows float where they open instead of being tiled into `B`.
- **One monitor:** PiP follows you to every workspace you switch to.
- **Two monitors:** PiP only moves when its workspace is no longer visible on
  any monitor. A PiP on the laptop display stays there while you switch
  workspaces on the LG, and the other way round.

## Configuration

Two additions to [aerospace.toml](../mac/.config/aerospace/aerospace.toml). No
existing rules, monitor assignments, or keybindings were changed.

1. A float rule placed **before** the Helium rule (the first matching
   `on-window-detected` rule wins, so order matters):

   ```toml
   [[on-window-detected]]
   if.app-id = 'net.imput.helium'
   if.window-title-regex-substring = '(?i)^picture-in-picture$'
   run = 'layout floating'
   ```

2. The workspace-change hook:

   ```toml
   exec-on-workspace-change = ['/Users/vp/.local/bin/aerospace-pip-follow']
   ```

The helper lives at
[mac/.local/bin/aerospace-pip-follow](../mac/.local/bin/aerospace-pip-follow)
and is symlinked to `~/.local/bin/aerospace-pip-follow`.

## How the helper works

On each workspace change, using `AEROSPACE_FOCUSED_WORKSPACE`:

1. One `aerospace list-windows --app-bundle-id net.imput.helium` query, filtered
   for the title `Picture-in-Picture` (case-insensitive). If there is no PiP, it
   exits here.
2. Otherwise it lists visible workspaces across all monitors.
3. Any PiP whose workspace is not visible is moved to the focused workspace.

Cost is about 10 to 20ms per switch, with negligible CPU.

## Design constraints (why it replaced the old guardian)

The previous [PiP guardian](aerospace-pip-guardian.md) was removed on 2026-10-03
because it ran `osascript` System Events queries on every switch (CPU heavy) and
sometimes activated Brave with a `sleep`, stealing focus. Keep this helper:

- aerospace CLI only. No `osascript`, no `swift`, no app activation, no `sleep`.
- Early exit when no PiP exists.
- Title matching case-insensitive. Helium has reported both
  `Picture-in-picture` and `Picture-in-Picture` across versions.

## Not covered

- **YouTube Brave PWA PiP.** That PiP belongs to a hidden parent `Brave Browser`
  process and can end up offscreen. Workaround: activate Brave Browser manually.
- **mpv.** mpv floats and stays on top but does not follow workspaces. It could
  be added to the helper by also matching `io.mpv`.

## Troubleshooting

```sh
# Is the PiP managed, and what is its title and layout?
aerospace list-windows --all --format '%{window-id}%{tab}%{app-bundle-id}%{tab}%{workspace}%{tab}%{window-layout}%{tab}%{window-title}' | grep -i picture

# Run the helper by hand for a given workspace
AEROSPACE_FOCUSED_WORKSPACE=B ~/.local/bin/aerospace-pip-follow
```

- PiP tiled into `B`: the float rule is missing or sits below the Helium rule.
- PiP does not follow: check the symlink exists and is executable, and that
  the title still matches.

To disable, remove the two config blocks and run `aerospace reload-config`.

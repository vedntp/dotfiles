# AeroSpace Picture-in-Picture Guardian (removed)

Removed on 2026-10-03 at the user's request after disruptive behavior. The
helper, deployed symlink, workspace-change hook, and Ctrl+Alt+P recovery binding
are gone. A lightweight replacement was added on 2026-10-15: see
[aerospace-pip-follow.md](aerospace-pip-follow.md).

The remainder is historical documentation. Its commands are no longer available
and should not be used as current setup instructions.

`~/.local/bin/aerospace-pip-guardian` keeps supported picture-in-picture windows visible while switching AeroSpace workspaces.

## Behavior

The guardian has two modes:

- `auto` runs through AeroSpace's `exec-on-workspace-change` hook. It makes AeroSpace-managed Helium PiP windows floating, moves them to the focused workspace, and activates Brave when a hidden Brave parent process owns a YouTube PWA PiP window.
- `recover` runs from `Ctrl+Alt+P`. It performs the automatic behavior and recreates a stale Helium native PiP window when CoreGraphics can see it but AeroSpace cannot.

Helium and Brave are handled separately. Helium failures are usually managed-window or stale-native-window problems. YouTube PWA failures are usually caused by a hidden parent Brave process.

## Helium title matching

PiP window-title capitalization is not stable across versions:

- Current Helium: `Picture-in-Picture`
- Older Helium and Brave versions: `Picture-in-picture`

All guardian title comparisons must remain case-insensitive.

On 2026-08-17, Helium PiP following and recovery stopped working because the guardian matched `Picture-in-picture` exactly while Helium reported `Picture-in-Picture`. AeroSpace still managed the window, but the guardian skipped it and left it on its original workspace. Case-insensitive matching fixed automatic following, managed-window detection, and native-window detection.

## Diagnosis

Check the focused workspace and AeroSpace's window metadata:

```sh
aerospace list-workspaces --focused
aerospace list-windows --all --format '%{window-id}\t%{app-bundle-id}\t%{workspace}\t%{window-title}'
```

A managed Helium PiP window has bundle ID `net.imput.helium`. Its title should be treated case-insensitively as `picture-in-picture`.

Run automatic handling directly:

```sh
~/.local/bin/aerospace-pip-guardian auto
```

Run stronger recovery when Helium's native PiP exists but is absent from `aerospace list-windows --all`:

```sh
~/.local/bin/aerospace-pip-guardian recover
```

For a missing YouTube PWA PiP window, check whether the `Brave Browser` process is hidden even though the visible YouTube app window is not. Activating the parent Brave process restores that PiP case.

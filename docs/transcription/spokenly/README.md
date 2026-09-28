# Spokenly Input Profile

Last audited against the installed app and live preferences: 2026-09-09

## Profile Summary

| Field | Value |
| --- | --- |
| Provider ID | `spokenly` |
| Application | Spokenly |
| Installed version | `2.27.16` (`538`) |
| Bundle ID | `app.spokenly` |
| URL scheme | `spokenly://` |
| Current mode | `Default Mode` |
| Current mode ID | `00000000-0000-4000-8000-000000000001` |
| Output action | Auto-insert |
| In-app shortcut | Fn |
| In-app activation mode | Push-to-talk |
| Classification | Custom user selection in Spokenly |

Spokenly is the sole configured transcription provider. Its CLI is not
currently installed under `/usr/local/bin/`.

## Keyboard Activation Semantics

Right Option is handled by the local bridge so it shares Spokenly's toggle
state with the MX Master and trackpad helpers:

| Input | Result |
| --- | --- |
| MacBook physical Right Option | Bridge toggles the `test` mode via its mode-specific deeplink |
| Ducky physical right GUI, immediately right of right Alt | Emits Right Option, then the bridge toggles the `test` mode |

The Ducky hardware Fn key is firmware-only and is not exposed to macOS. The
bridge uses a listen-only Core Graphics event tap and waits 120 ms to
distinguish a bare modifier tap from a key chord.

## Live Preference Representation

The current profile is stored in `modes.v2` inside:

```text
~/Library/Preferences/app.spokenly.plist
```

`modes.v2` is JSON stored as plist data. Its shortcut-relevant shape is:

```json
{
  "name": "Default Mode",
  "id": "00000000-0000-4000-8000-000000000001",
  "modeMac": "autoInsert",
  "shortcut": {
    "id": "00000000-0000-4000-8000-000000000001",
    "activationMode": "automatic",
    "trigger": {
      "keys": {
        "_0": {
          "rawFlags": 64
        }
      }
    }
  }
}
```

`rawFlags: 0` disables Spokenly's native Right Option trigger. The bridge owns
the physical event and opens the documented toggle deeplink. The original
`rawFlags: 64` value is preserved in
`~/.dotfiles/backups/spokenly/modes.v2.before-native-shortcut-disable.json` for
rollback.

## Trackpad Tap Ownership

The MacBook trackpad's three-finger tap is now owned by Three Finger Switcher.
The switcher waits for release, accepts only a 5 to 600 ms contact with no
more than 2.0 mm of per-finger travel, and then launches
`~/Applications/Spokenly Toggle.app`, which calls `spokenly://toggle`. A
right swipe that reaches the switcher's 3.5 mm threshold opens the app switcher
and supports two-finger scrubbing. A left swipe reaches the same threshold,
waits 40 ms for direction confirmation, and sends one context-aware line-clear
shortcut. The cached frontmost app selects `Ctrl+U` in Ghostty, Alacritty,
Terminal, cmux, Warp, and iTerm2, suppresses the shortcut in Three Finger
Switcher, Finder, Mail, Messages, Notes, Reminders, Calendar, and Photos, and
uses `Cmd+Delete` in every other, unknown, or missing-bundle application. The
cache lookup adds negligible latency. All behaviors are owned by the background
Three Finger Switcher process.

The competing unnamed Spokenly mode with trigger `threeFingerLight` was backed
up before being deleted. This prevents Spokenly's own light three-finger
recognizer from firing before the switcher can classify the interaction.

Three Finger Switcher applies whole-frame palm rejection before this tap path.
Rejected contacts cannot toggle Spokenly or become an apparent release. The
stronger 2026-08-29 calibration is pending physical verification; its exact
thresholds and rollback procedure are maintained in the
[Three Finger Switcher guide](../../three-finger-switcher.md).

## Current Device Compatibility

| Device | Physical input | Route |
| --- | --- | --- |
| MacBook keyboard | Right Option | Right Option bridge toggles the `test` mode |
| Ducky One 2 | Physical right GUI, immediately right of right Alt | Native mapping to Right Option, then the bridge toggles the `test` mode |
| MacBook trackpad | Three-finger tap, classified on release by Three Finger Switcher | Opens `Spokenly Toggle.app`, which calls `spokenly://toggle` |
| MX Master 3S | Auxiliary/thumb button `c195` | Logitech Smart Action opens `Spokenly Toggle.app`, which calls `spokenly://toggle` |

Three Finger Switcher owns the MacBook trackpad tap and swipe arbitration.
BetterTouchTool's former three-finger trackpad triggers are disabled so they do
not race the switcher. The Magic Mouse route remains owned by its current
BetterTouchTool trigger where configured.

## Keyboard modifier ownership

The Ducky One 2 Command, Option, and Caps mappings are owned by native macOS in
`com.apple.keyboard.modifiermapping.1241-661-0`. The right-side mapping keeps
physical right Alt as Right Command and maps physical right GUI to Right Option.
This emits the same native Right Option event that the MacBook key emits.

## Spokenly Automation Hooks

Spokenly exposes official deeplinks that may help later automation:

| Action | Deeplink |
| --- | --- |
| Start main mode | `spokenly://start` |
| Stop recording | `spokenly://stop` |
| Toggle recording | `spokenly://toggle` |
| Start a mode | `spokenly://start?mode_id=<id>` |
| Toggle a mode | `spokenly://toggle?mode_id=<id>` |
| Switch mode without recording | `spokenly://switch?mode_id=<id>` |
| Open keyboard controls | `spokenly://tab/shortcuts` |

Source: [Spokenly deeplink documentation](https://spokenly.app/docs/macos/deeplinks).
These deeplinks control recording and modes. The MX Master hands-free route
uses the documented toggle deeplink through the background helper. The URL
handler resolves to the installed Spokenly application without foreground
activation.

## Sources Of Truth

| System | Source |
| --- | --- |
| Spokenly application metadata | `/Applications/Spokenly.app/Contents/Info.plist` |
| Spokenly live preferences | `~/Library/Preferences/app.spokenly.plist` |
| Spokenly mode shortcut | `modes.v2` in the live preferences |
| Logitech Options+ profiles | `~/Library/Application Support/LogiOptionsPlus/settings.db` |
| Logitech Smart Actions | `~/Library/Application Support/LogiOptionsPlus/macros.db` |
| Spokenly toggle helper | `mac/.local/libexec/spokenly-toggle/` and `~/Applications/Spokenly Toggle.app` |
| Right Option bridge | `mac/.local/bin/spokenly-right-option-listener.swift` and `com.vp.spokenly-right-option-listener` LaunchAgent |
| Official activation styles | [Spokenly Modes](https://spokenly.app/docs/modes) |
| Official automation hooks | [Spokenly Deeplinks](https://spokenly.app/docs/macos/deeplinks) |

## Verification Checklist

The Three Finger Switcher tap and directional swipe integration was physically
verified by the user on 2026-08-22. The checklist remains useful after future
Spokenly, macOS, or switcher updates.

1. Confirm Spokenly is running and idle.
2. Press MacBook Right Option and confirm the bridge toggles Spokenly.
3. Press the Ducky key immediately right of right Alt and confirm the bridge
   toggles the same recording.
4. Make a deliberate three-finger tap and confirm the switcher toggles Spokenly
   once after release.
5. Reproduce a palm rest or broad accidental contact and confirm it produces no
   Spokenly, app-switcher, or line-clear action.
6. Make a three-finger swipe right and confirm it opens the app switcher
   without toggling Spokenly; keep two fingers down and confirm scrubbing.
7. Make a three-finger swipe left in a terminal and confirm one `Ctrl+U`; test
   an ordinary text app for one `Cmd+Delete`, and confirm a denylisted app is
   suppressed.
8. Press the MX Master auxiliary/thumb button and confirm it toggles Spokenly.
9. Start with either Right Option or the MX Master button, then stop with the
   other input. Confirm that no second recording starts.

## Rollback

To return tap ownership to Spokenly, disable or quit Three Finger Switcher,
restore the backed-up `modes.v2` entry for the unnamed `threeFingerLight` mode
through Spokenly's settings, and re-enable its three-finger gesture. Keep the
switcher's former BetterTouchTool app-switcher triggers disabled until only one
owner is selected for the trackpad gesture.

## Known gap: Right Option bridge files are not tracked (2026-09-29)

The docs above describe the `com.vp.spokenly-right-option-listener` LaunchAgent
and `spokenly-right-option-listener.swift`. As of 2026-09-29 neither file
exists in this repository or its git history. The Stow symlinks
`~/.local/bin/spokenly-right-option-listener.swift` and
`~/Library/LaunchAgents/com.vp.spokenly-right-option-listener.plist` are
dangling, so the bridge is probably not running. Spokenly's native Right Option
trigger is disabled (`rawFlags: 0`), which means Right Option may currently do
nothing.

To fix: either recreate the listener (listen-only CGEventTap, 120 ms bare-tap
window, opens the `spokenly://toggle?mode_id=...` deeplink) and add both files
under `mac/`, or restore `rawFlags: 64` from
`backups/spokenly/modes.v2.before-native-shortcut-disable.json`.

# Spokenly Input Profile

Last audited against the installed app and live preferences: 2026-08-22

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

Right Option is the only active keyboard shortcut:

| Input | Result |
| --- | --- |
| MacBook physical Right Option | Activates Spokenly's Default Mode directly |
| Ducky physical right GUI, immediately right of right Alt | Emits Right Option and activates the same Default Mode directly |

The Ducky hardware Fn key is firmware-only and is not exposed to macOS. The MX
Master thumb button remains a separate hands-free toggle route through the
background helper.

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

`rawFlags: 64` is the live serialization of the Right Option modifier trigger.
Prefer Spokenly's settings UI when changing it instead of treating this private
encoding as a stable public API.

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
cache lookup adds negligible latency. All behaviors are controlled by the
switcher's **Enable Three-Finger Gestures** menu item.

The competing unnamed Spokenly mode with trigger `threeFingerLight` was backed
up before being deleted. This prevents Spokenly's own light three-finger
recognizer from firing before the switcher can classify the interaction.

## Current Device Compatibility

| Device | Physical input | Route |
| --- | --- | --- |
| MacBook keyboard | Right Option | Direct Spokenly Default Mode shortcut |
| Ducky One 2 | Physical right GUI, immediately right of right Alt | Native macOS mapping to Right Option, then the same direct Spokenly shortcut |
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
| Official activation styles | [Spokenly Modes](https://spokenly.app/docs/modes) |
| Official automation hooks | [Spokenly Deeplinks](https://spokenly.app/docs/macos/deeplinks) |

## Verification Checklist

The Three Finger Switcher tap and directional swipe integration was physically
verified by the user on 2026-08-22. The checklist remains useful after future
Spokenly, macOS, or switcher updates.

1. Confirm Spokenly is running and idle.
2. Press MacBook Right Option and confirm Spokenly activates its Default Mode.
3. Press the Ducky key immediately right of right Alt and confirm it activates
   the same mode.
4. Make a deliberate three-finger tap and confirm the switcher toggles Spokenly
   once after release.
5. Make a three-finger swipe right and confirm it opens the app switcher
   without toggling Spokenly; keep two fingers down and confirm scrubbing.
6. Make a three-finger swipe left in a terminal and confirm one `Ctrl+U`; test
   an ordinary text app for one `Cmd+Delete`, and confirm a denylisted app is
   suppressed.
7. Press the MX Master auxiliary/thumb button and confirm it toggles Spokenly.

## Rollback

To return tap ownership to Spokenly, disable or quit Three Finger Switcher,
restore the backed-up `modes.v2` entry for the unnamed `threeFingerLight` mode
through Spokenly's settings, and re-enable its three-finger gesture. Keep the
switcher's former BetterTouchTool app-switcher triggers disabled until only one
owner is selected for the trackpad gesture.

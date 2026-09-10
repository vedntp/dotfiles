# Spokenly Transcription Setup

## Purpose

This directory documents the current Spokenly input setup:

- The application's built-in defaults.
- The shortcuts customized in this setup.
- The physical input paths for the MacBook and Ducky keyboards, MacBook
  trackpad, MX Master 3S, and Magic Mouse.
- Verification notes and source-of-truth paths.

Keeping these categories separate is important. A shortcut appearing in an
application's saved preferences does not necessarily mean it was created in
this dotfiles setup.

## Current Provider

| Provider | Profile | Status |
| --- | --- | --- |
| Spokenly | [Spokenly profile](spokenly/README.md) | Installed and verified against the current live configuration |

Spokenly is the sole configured transcription provider. Additional providers
should be audited independently before adding their shortcuts or device routes.

## Current Spokenly Input Path

Spokenly uses its direct Right Option shortcut with automatic activation:

| Physical input | Owner | Action |
| --- | --- | --- |
| MacBook physical Right Option | Spokenly | Activates the Default Mode directly |
| Ducky physical right GUI, immediately right of right Alt | Native macOS Ducky modifier mapping, then Spokenly | Emits Right Option and activates the same Default Mode directly |
| MacBook trackpad three-finger tap | Three Finger Switcher | On release, launches `Spokenly Toggle.app` and calls `spokenly://toggle` |
| MX Master auxiliary/thumb button | Logitech Options+ | Opens `Spokenly Toggle.app`, which calls `spokenly://toggle` |

Three Finger Switcher exclusively arbitrates the MacBook trackpad's
three-finger tap and horizontal swipe. A 5 to 600 ms tap with no more than
2.0 mm of per-finger travel toggles Spokenly after release. A right swipe that
reaches the existing threshold opens the app switcher with two-finger
scrubbing. A left swipe reaches the same threshold, waits 40 ms for direction
confirmation, then sends one context-aware line-clear shortcut. It uses
`Ctrl+U` in Ghostty, Alacritty, Terminal, cmux, Warp, and iTerm2, is suppressed
in Three Finger Switcher, Finder, Mail, Messages, Notes, Reminders, Calendar,
and Photos, and uses `Cmd+Delete` in every other, unknown, or missing-bundle
application. The frontmost application lookup is cached and adds negligible
latency. See the
[Spokenly input profile](spokenly/README.md) and the
[Three Finger Switcher guide](../three-finger-switcher.md) for the live
preference serialization, calibration, and verification steps.

The switcher applies its own whole-frame palm filter before classifying the
trackpad route. The stronger 2026-08-29 calibration remains pending physical
verification and does not modify macOS palm rejection.

The competing unnamed Spokenly `threeFingerLight` mode was backed up and
deleted, so Spokenly's built-in recognizer cannot race the switcher. The
background switcher owns both tap and swipe behavior.

## Documentation Rules

- Label every shortcut as `Built-in default`, `Custom`, or `Removed`.
- Record live behavior separately from historical experiments.
- Keep stable trigger IDs, slot IDs, bundle IDs, and source-of-truth paths.
- Update [the quick shortcut reference](../shortcut-reference.md) when current
  behavior changes.
- Keep detailed Logitech and BetterTouchTool troubleshooting in their existing
  setup guides.

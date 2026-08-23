# Ducky One 2 - macOS Setup

## Problem

Ducky One 2 doesn't have a Mac/Windows switch like Keychron. By default:
- Alt key → Option (⌥)
- Windows key → Command (⌘)

This is reversed from Mac layout where Command should be next to the spacebar.

## Solution

The Ducky-specific Command, Option, and Caps mappings are owned by native
macOS keyboard preferences, serialized under
`com.apple.keyboard.modifiermapping.1241-661-0`. No additional keyboard
remapper is required for the Ducky or any other keyboard.

Other keyboards, including the MacBook built-in keyboard, are unaffected by
the Ducky-specific preference.

## Spokenly keyboard behavior

Spokenly's direct shortcut is native Right Option. On the MacBook, use physical
Right Option. On the Ducky, use the physical right GUI key immediately to the
right of right Alt. The Ducky-specific macOS mapping emits Right Option from
that key, while right Alt remains Right Command.

No Ducky key launches an adapter application or calls a Spokenly deeplink. The
Ducky hardware Fn key remains firmware-only and is not exposed to macOS.

## Function Row

The Ducky hardware Fn key is handled by the keyboard firmware. macOS does not
see it as the MacBook Fn/Globe key, and `Fn+F1-F12` is not the right path for
Mac media keys on this board.

`~/.local/bin/ducky-one-2-media-keys` maps the media keys below with `hidutil`,
targeted to the Ducky vendor/product ID only. A LaunchAgent at
`~/Library/LaunchAgents/com.vp.ducky-one2-media-keys.plist` reapplies the
mapping on login and every 30 seconds so it survives keyboard replugging.

- Triple F4 → BetterTouchTool's global key sequence locks the screen using its
  native Lock Screen action. Single and double F4 presses have no custom
  action. F4 passes through the F8 listener unchanged so BTT can recognize it.
- MacBook built-in F4 → `~/.local/bin/macbook-f4-proton-key` remaps Apple's
  Spotlight/Search HID usage to normal F4, targeted only to the built-in Apple
  keyboard so it does not overwrite the Ducky media mapping. The helper keeps
  its legacy filename, but F4 no longer controls Proton VPN.
- F8 → the same listener calls `~/.local/bin/aerospace-toggle-enabled` to
  kill/relaunch the official `/Applications/AeroSpace.app` process.
  A LaunchAgent at
  `~/Library/LaunchAgents/com.vp.ducky-f8-aerospace-listener.plist` keeps the
  listener running.
- F10 → Mute
- F11 → Volume Down
- F12 → Volume Up

## Herdr Prefix Across Keyboards

Herdr uses `Ctrl+B` as its canonical prefix in
`~/.config/herdr/config.toml`.

- Ducky One 2: press physical `Ctrl+B`. The Ducky Fn key cannot be used
  because its firmware does not expose that key to macOS.
- MacBook keyboard: the native
  `~/.local/bin/macbook-fn-herdr-listener`, kept running by
  `~/Library/LaunchAgents/com.vp.macbook-fn-herdr-listener.plist`, reads the
  built-in keyboard's raw Fn/Globe HID value. It emits `Ctrl+B` only for a
  standalone Fn tap of no more than 0.35 seconds when either Ghostty
  (`com.mitchellh.ghostty`) or Alacritty (`org.alacritty`) is frontmost at both
  press and release. It passes all physical input through unchanged.

The raw input source is the built-in Apple keyboard's IOHID element, vendor
`0x05AC`, product `0x0342`, usage page `0xFF`, usage `0x03`. It reports explicit
down and up values. A separate listen-only event tap invalidates the tap if
another key, modifier, or system-defined media event participates, including a
modifier held before Fn is pressed.

The former BetterTouchTool trigger, `Ghostty Fn to Ctrl+B - Herdr prefix`
(`3D18BB81-90D9-4CD9-BED3-9B46FBB2F683`), is disabled but preserved as the
immediate rollback path. It must remain disabled while the native listener is
active so one Fn tap cannot emit two `Ctrl+B` prefixes.

macOS **Press Globe key to** is set to **Do Nothing**
(`com.apple.HIToolbox AppleFnUsageType = 0`) so the native Globe action does not
compete with the listener's terminal-scoped mapping. This means the MacBook
Fn/Globe key does nothing outside Ghostty and Alacritty when pressed by itself.

The Ducky-specific function-row mappings remain unchanged. In particular,
Ducky F12 is still Volume Up rather than a Herdr prefix.

### Listener Files and Permissions

| Purpose | Path or label |
| --- | --- |
| Tracked Swift source | `~/.dotfiles/mac/.local/bin/macbook-fn-herdr-listener.swift` |
| Compile/exec wrapper | `~/.local/bin/macbook-fn-herdr-listener` |
| Compiled binary | `~/Library/Caches/dotfiles/macbook-fn-herdr-listener` |
| LaunchAgent label | `com.vp.macbook-fn-herdr-listener` |
| Runtime log | `~/Library/Logs/macbook-fn-herdr-listener.log` |

The wrapper compiles into the stable cache path, ad-hoc signs the binary with
identifier `com.vp.macbook-fn-herdr-listener`, and executes it. System Settings
must grant the compiled binary both Input Monitoring and Device Control and
Data Access. Grant the cache binary itself, not the shell wrapper. After a
recompile, macOS may retain a stale path-based permission record. If the log
shows `result=-536870174` or an Accessibility warning, remove the old
same-named entry, add the exact compiled binary again in both panes, and restart
the LaunchAgent.

### Verification and Rollback

The quick-tap path was physically verified in Ghostty on 2026-08-15 and in
Alacritty on 2026-08-16. In both terminals, one quick Globe/Fn tap produced
exactly one `Ctrl+B`; the Alacritty test also recorded
`allowedTerminal=true` followed by one `Fn tap triggered Ctrl+B` log entry.

Useful checks:

```sh
launchctl print gui/$(id -u)/com.vp.macbook-fn-herdr-listener
tail -f ~/Library/Logs/macbook-fn-herdr-listener.log
defaults read com.apple.HIToolbox AppleFnUsageType
```

For rollback, unload `com.vp.macbook-fn-herdr-listener`, restore
`AppleFnUsageType` to `3`, and re-enable only preserved BTT trigger
`3D18BB81-90D9-4CD9-BED3-9B46FBB2F683` after BTT is available. Do not change
any unrelated BTT trigger.

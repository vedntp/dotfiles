# BetterTouchTool Gesture Setup

Last audited: 2026-08-22

## Goal

Keep BetterTouchTool inputs predictable across the MacBook trackpad and Magic
Mouse. Logitech Options+ remains the owner of the MX Master 3S.

The current setup uses BTT for the remaining MacBook trackpad and Magic Mouse
gestures. Three Finger Switcher owns the MacBook trackpad's three-finger tap
and horizontal swipe arbitration:

- Triple F4 locks the screen through BTT's native Lock Screen action.
- 4-finger tap sends `Return`.
- In Codex only, 2-finger swipe right opens the chat switcher list with one
  `Ctrl+Tab` hold window. Lifting the final trackpad finger clicks the currently
  hovered chat and releases Control.
- In Codex only, `Ctrl+B` toggles the sidebar organization between `By project`
  and `In one list`.
- Magic Mouse 1-finger tap performs a standard left click.
- Magic Mouse 1-finger tap right performs a standard right click.
- Magic Mouse 2-finger swipe right opens BTT's native Application Switcher.
- Magic Mouse 3-finger tap performs a standard middle click globally.
- In Codex only, Magic Mouse 3-finger tap sends `Return`.
- The former 3-finger click and swipe triggers are absent from the live BTT data
  store so they cannot race Three Finger Switcher.
- Ducky One 2 F4 passes through to BTT. F8 is handled outside BTT by
  `~/.local/bin/ducky-f8-aerospace-listener`, which calls
  `~/.local/bin/aerospace-toggle-enabled`, which toggles the official
  `/Applications/AeroSpace.app`.
  A LaunchAgent keeps the F8 listener running.
- MacBook built-in F4 is first remapped from Apple's Spotlight/Search HID usage
  to normal F4 by `~/.local/bin/macbook-f4-proton-key`, then recognized by BTT.
  The remap is scoped to the built-in Apple keyboard so it does not overwrite
  Ducky media-key mappings. The helper retains its legacy filename even though
  F4 no longer controls Proton VPN.

The MacBook Globe/Fn Herdr prefix is no longer owned by BTT. A native listener
reads explicit Fn down/up values from the built-in keyboard and emits `Ctrl+B`
only for a quick standalone Fn tap in Ghostty or Alacritty. BTT trigger
`3D18BB81-90D9-4CD9-BED3-9B46FBB2F683` is disabled and retained only as an
immediate rollback path. See
[the keyboard setup](../ducky-one-2-setup.md#herdr-prefix-across-keyboards)
for the listener's timing, app scope, and LaunchAgent.

Related input docs:

- [Logitech Options+ and Spokenly setup](../logitech-options-spokenly.md)
- [Spokenly transcription profile](../transcription/spokenly/README.md)
- [Three Finger Switcher](../three-finger-switcher.md)

The former Spokenly unnamed `threeFingerLight` mode was backed up and deleted
when this ownership moved to Three Finger Switcher. To roll back, disable or
quit the switcher, restore that `modes.v2` entry through Spokenly's settings,
and leave the superseded BTT three-finger triggers disabled until the desired
single owner is selected.

## Source of Truth

BetterTouchTool is installed at:

```text
/Applications/BetterTouchTool.app
```

The live trigger database is under:

```text
~/Library/Application Support/BetterTouchTool/btt_data_store.version_*
```

Preferences plist:

```text
~/Library/Preferences/com.hegenberg.BetterTouchTool.plist
```

BTT's `get_triggers` AppleScript command is the quickest live audit path. Its
bundled trigger reference is useful when checking gesture IDs:

```text
/Applications/BetterTouchTool.app/Contents/Resources/trigger-definitions.mdx
```

## Native Globe/Fn Herdr Adapter

The native adapter owns only this former BTT behavior:

```text
MacBook Globe/Fn quick tap in Ghostty or Alacritty
  -> raw built-in keyboard Fn down/up
  -> native listener validation
  -> one synthetic Ctrl+B
  -> Herdr prefix
```

The listener uses the built-in Apple keyboard's IOHID element, vendor `0x05AC`,
product `0x0342`, usage page `0xFF`, usage `0x03`. IOHID supplies explicit `1`
and `0` values for Fn down and up, avoiding ambiguous `flagsChanged` events when
the macOS bare-Globe action is disabled. A listen-only Core Graphics event tap
cancels the candidate tap when another key, modifier, or system-defined media
event participates. Modifiers already held at Fn-down are checked separately.

The prefix is emitted only when all of these conditions hold:

- Ghostty or Alacritty is frontmost at both Fn-down and Fn-up.
- Fn is released within `0.35` seconds.
- No other key or modifier participates.

Tracked and live interfaces:

| Purpose | Path or label |
| --- | --- |
| Swift source | `~/.dotfiles/mac/.local/bin/macbook-fn-herdr-listener.swift` |
| Compile/exec wrapper | `~/.local/bin/macbook-fn-herdr-listener` |
| Compiled binary | `~/Library/Caches/dotfiles/macbook-fn-herdr-listener` |
| LaunchAgent | `com.vp.macbook-fn-herdr-listener` |
| LaunchAgent plist | `~/Library/LaunchAgents/com.vp.macbook-fn-herdr-listener.plist` |
| Runtime log | `~/Library/Logs/macbook-fn-herdr-listener.log` |

The compiled binary, not the shell wrapper, must be enabled in both **Input
Monitoring** and **Device Control and Data Access** in System Settings. If a
source change recompiles the binary and macOS rejects the new signature, remove
the stale same-named permission entry, add the exact compiled binary path above,
and restart the LaunchAgent.

The quick-tap path was physically verified in Ghostty on 2026-08-15 and in
Alacritty on 2026-08-16. In both terminals, one quick Globe/Fn tap produced
exactly one `Ctrl+B`; the Alacritty test also logged
`allowedTerminal=true` followed by exactly one `Fn tap triggered Ctrl+B` entry.

Rollback keeps unrelated BTT settings untouched: stop
`com.vp.macbook-fn-herdr-listener`, restore `AppleFnUsageType` to `3`, and
re-enable only BTT trigger `3D18BB81-90D9-4CD9-BED3-9B46FBB2F683` after BTT is
available again.

## Current Trackpad Gestures

Current global trackpad gestures still owned by BTT:

| Gesture | BTT trigger type | BTT action / shortcut |
| --- | --- | --- |
| 4-finger tap | `110` | `36` / Return, sends Enter |

Three Finger Switcher owns the MacBook trackpad's three-finger interactions.
Its valid tap path waits for release, then launches `Spokenly Toggle.app`. A
rightward horizontal movement that reaches the existing threshold opens the
macOS app switcher, while a leftward movement emits one context-aware
line-clear shortcut. See [the switcher guide](../three-finger-switcher.md) for
the 5 to 600 ms tap window, 2.0 mm travel allowance, application routing, and
the pending 2026-08-29 palm-filter calibration. Palm rejection belongs to
Three Finger Switcher, not BTT.
Current BTT UUIDs:

| Gesture | UUID |
| --- | --- |
| 4-finger tap | `A693727F-81DC-4CD4-B643-21A0D68705F8` |

Removed / superseded BTT triggers:

| Gesture | BTT trigger type | Previous shortcut | UUID | Status |
| --- | --- | --- | --- | --- |
| 3-finger swipe right | `101` | `46` / Application Switcher | `D31D7DAB-04F5-4A03-8EB7-469C8B9F9B01` | Removed from live data; superseded by Three Finger Switcher |
| 3-finger swipe left | `100` | `55,51` / Cmd+Delete | `94E64D33-7972-4F71-A04A-09A4D75C4B15` | Removed from live data; superseded by context-aware Three Finger Switcher routing |
| 3-finger click | `112` | `36` / Return | `44022E95-1E33-48C6-BAC4-D7838FFBD70A` | Removed from live data; no longer reserved |

## Triple F4 Lock

The global key-sequence trigger
`1603FFF1-E362-4179-A64A-F08074D9FDE5` recognizes three complete F4 presses,
six ordered key-down and key-up events, with at most `0.35` seconds between
events. The key-sequence trigger itself runs BTT action `158` / Lock Screen.

The key sequence is recognized on all connected keyboards. The MacBook
built-in F4 Search key is normalized to ordinary F4 by
`~/.local/bin/macbook-f4-proton-key`. The Ducky already emits ordinary F4.
Single and double F4 presses no longer toggle Proton VPN and do not run a BTT
action.



## App-Specific Gestures

Current app-specific gestures:

| App | Bundle ID | Gesture | BTT trigger type | BTT action / shortcut | UUID |
| --- | --- | --- | --- | --- | --- |
| Codex | `com.openai.codex` | 2-finger swipe right | `160` | `137` / terminal command, lift to select | `B3FE5023-2A6D-4A7B-908D-2DB2815F700D` |
| Codex | `com.openai.codex` | `Ctrl+B` | `0` | `137` / terminal command, toggle sidebar organization | `0879D751-4B2D-44EB-8610-F4F6F136BA27` |
| Codex | `com.openai.codex` | Magic Mouse 3-finger tap | `9` | `36` / Return, sends Enter | `C7595FBE-FF9E-402C-84A6-915C1EFB0D4E` |

Current BTT automation triggers:

| Trigger | BTT trigger type | Action | UUID |
| --- | --- | --- | --- |
| Triple F4 | `624` / key sequence | `158` / Lock Screen | `1603FFF1-E362-4179-A64A-F08074D9FDE5` |

The Ducky F8 listener is owned by the LaunchAgent
`~/Library/LaunchAgents/com.vp.ducky-f8-aerospace-listener.plist`, not BTT.

The Codex trigger runs this helper:

```text
~/.local/bin/btt-codex-chat-switcher
```

The helper calls this compiled Swift event sender:

```text
~/.local/bin/btt-codex-key-event
```

The Swift helper sends explicit keyboard events: Control flagsChanged down,
Tab down/up with the Control flag set, a left click at the current pointer
position, and Control flagsChanged up. The helper sends one `Ctrl+Tab` to open
Codex's chat switcher, keeps Control held, then BTT's no-touch hook runs the
selection helper when the last trackpad finger lifts. It intentionally does not
repeat while sliding, and it does not define a left-swipe trigger.

The no-touch hook runs this reusable named trigger:

| Named trigger | BTT trigger type | Action | UUID |
| --- | --- | --- | --- |
| `codex_chat_switcher_select_hovered_chat` | `643` | `137` / `~/.local/bin/btt-codex-chat-switcher select` | `8BD35B3E-20C0-4062-9B93-6B2D1A2B762C` |

The shell helper currently uses a `12.0` second failsafe release window in case
the no-touch hook does not fire. On lift-to-select, it waits `0.001` seconds
before clicking the current pointer position. The click itself holds mouse-down
for `0.001` seconds before mouse-up.

When opening the switcher, the shell helper waits `0.001` seconds after Control
down before sending Tab.

Tracked source for the event sender:

```text
~/.dotfiles/mac/.local/bin/btt-codex-key-event.swift
```

Tracked source for the shell helper:

```text
~/.dotfiles/mac/.local/bin/btt-codex-chat-switcher
```

Compile/update the live helper with:

```sh
swiftc ~/.dotfiles/mac/.local/bin/btt-codex-key-event.swift -o ~/.local/bin/btt-codex-key-event
install -m 755 ~/.dotfiles/mac/.local/bin/btt-codex-chat-switcher ~/.local/bin/btt-codex-chat-switcher
```

The BTT trigger uses action `137` (`Execute Terminal Command`, async), rather
than action `206` (`Shell Script Task`), because `206` did not execute when
tested through BTT's scripting interface in this setup. Earlier attempts using
BTT's native `Control Down` action and `System Events` did not create a durable
held Control state.

The trigger has `Retrigger after sliding` disabled in the database
(`ZALLOWRETRIGGER=0`) and the live repeat delay/rate fields are `0.0`.

The 2-finger swipe sensitivity is explicitly tuned lower than the BTT default
to match the 3-finger app switcher swipe:

```sh
defaults read com.hegenberg.BetterTouchTool tpTwoFingerSwipeSensitivity
```

Current value: `0.05`.

### Codex Sidebar Organization Shortcut

`Ctrl+B` toggles the Codex sidebar between these organization modes:

- `By project`
- `In one list`

The trigger is scoped to Codex through bundle ID `com.openai.codex`, so it does
not replace `Ctrl+B` in other applications. In text fields that follow standard
macOS and Emacs-style navigation, the original `Ctrl+B` behavior moves the
cursor backward by one character.

The BTT trigger runs this debounce wrapper:

```text
~/Library/Application Support/BetterTouchTool/CustomScripts/codex-sidebar-toggle-debounced
```

The wrapper calls the compiled helper:

```text
~/Library/Application Support/BetterTouchTool/CustomScripts/codex-sidebar-toggle
```

The compiled helper uses the macOS Accessibility API to find the visible Codex
sidebar options control. It opens the menu, detects the active organization
mode by its checkmark, and clicks the other mode. It can fall back from `Chat
sidebar options` to `Project sidebar options` when the main chat options
control is not visible.

The debounce wrapper creates this temporary lock directory:

```text
/tmp/com.vp.btt-codex-sidebar-toggle.lock
```

It keeps the lock for `1.5` seconds after invoking the compiled helper.
Logitech Options+ can emit the same keyboard shortcut more than once for a
single thumb-wheel movement. Without the lock, one movement can toggle to the
other sidebar mode and immediately toggle back, making the shortcut appear not
to work.

The working trigger uses BTT action `137` (`Execute Terminal Command`, async).
Action `206` (`Shell Script Task`) did not execute correctly for this shortcut
and was the cause of the initial failure.

No Codex or BTT restart is normally required after changing the trigger. BTT
must be running and retain Accessibility permission.

The matching Logitech Options+ Codex profile is named `ChatGPT` and targets
bundle ID `com.openai.codex`. Its relevant assignments are:

| Physical control | Logitech assignment | Result |
| --- | --- | --- |
| Back button | `Cmd+Delete` | Deletes to the beginning of the line |
| Forward button | `Shift+Return` | Inserts a new line without submitting |
| Thumb wheel left | `Ctrl+Tab` | Switches to the next tab |
| Thumb wheel right | `Cmd+K` | Opens Codex search |

The restored Logitech profile does not assign `Ctrl+B` to a mouse control.
The Codex BTT sidebar trigger and its debounce wrapper remain available for a
separate `Ctrl+B` source.

#### 2026-07-30 Detached Action Incident

After BetterTouchTool updated to `6.682`, `Ctrl+B` still reached its enabled
Codex trigger, but the trigger no longer ran a command. BTT Usage Statistics
continued to increase because they count the trigger activation even when the
trigger has no attached action.

The before-and-after BTT databases showed the failure:

- The `6.663` database contained trigger record `96` with an action child that
  ran `codex-sidebar-toggle-debounced`.
- The migrated `6.682` database retained trigger record `96` and its stable
  UUID `0879D751-4B2D-44EB-8610-F4F6F136BA27`, but the action child was absent.
- The debounce wrapper and compiled helper were still present and executable.
- The compiled helper still found the current Codex sidebar controls.
- Logitech continued to emit `Ctrl+B`, and BTT continued to receive it.

The most likely cause was BTT migration or cleanup of the trigger's previously
edited action sequence. That sequence had accumulated obsolete shell-task,
direct-helper, and debounce action records during earlier troubleshooting. The
database evidence does not prove BTT's exact internal migration decision, so
treat this as the strongest supported explanation rather than a confirmed
upstream bug.

The repair was to create one fresh action child on the existing trigger:

```text
Ctrl+B
  -> Execute Terminal Command (Async, non-blocking)
  -> "~/Library/Application Support/BetterTouchTool/CustomScripts/codex-sidebar-toggle-debounced"
```

The repaired configuration has one clear trigger-to-action relationship. A
future BTT update could still detach it, so test `Ctrl+B` after BTT updates. If
the BTT usage count increases but the sidebar does not change, first confirm
that the async terminal action is still present and points to the debounce
wrapper.

## App Switcher Mode

The BTT app-switcher mode below is retained as historical configuration and
rollback information for the MacBook trackpad. Its former three-finger
trackpad trigger is disabled because Three Finger Switcher now owns both
three-finger tap and horizontal swipe classification. The Magic Mouse
two-finger app-switcher trigger remains active.

BTT's special app switcher mode is enabled:

```sh
defaults read com.hegenberg.BetterTouchTool useSpecialAppSwitcher
defaults read com.hegenberg.BetterTouchTool specialAppSwitcher
defaults read com.hegenberg.BetterTouchTool specialAppSwitcherInfoShown
```

All should return `1`.

BTT's action editor shows `Use Gesture Mode` enabled for the retained
app-switcher action. Its own description says the switcher advances with more
taps or with scroll while fingers are still touching. Historically this meant:

- Three-finger swipe opened the app switcher.
- Two-finger scrolling can move through the app switcher.
- Continuing to glide with the same three fingers does not appear to be a
  supported built-in BTT behavior.

The 3-finger swipe sensitivity is explicitly tuned lower than the BTT default
so the app switcher activates with a shorter gesture:

```sh
defaults read com.hegenberg.BetterTouchTool BTTTpThreeFingerSwipeSensitivity
```

Current value: `0.05`.

Important for rollback: do not configure the app switcher gesture as a plain keyboard
shortcut like `Cmd+Tab` or `Shift+Cmd+Tab`. That only opens the macOS app
switcher and can leave it waiting for release/confirmation. The working setup
uses BTT's native Application Switcher action so the gesture behaves more like
the MX Master gesture button.

macOS's built-in 3-finger horizontal swipe is disabled in the matching
trackpad preference domains so it does not fight the current owner. Four-finger
horizontal swipe remains enabled for Spaces/full-screen navigation.

## Magic Mouse Gestures

Current Magic Mouse gestures:

| Gesture | BTT trigger type | BTT action / shortcut | UUID |
| --- | --- | --- | --- |
| 1-finger tap | `1` | `3` / Left Click at current mouse position | `73D46814-59D7-450D-8B99-FEB4FDE8CDF1` |
| 1-finger tap right | `3` | `4` / Right Click at current mouse position | `042FC1A5-03DD-4C9D-9424-C5D6297DABBC` |
| 2-finger swipe right | `6` | `46` / Application Switcher | `95B221B7-9EC1-4C8A-8D15-5542228FCF02` |
| 3-finger tap | `9` | `1` / Middle Click at current mouse position | `CFBD7467-2660-467F-ABB4-D30CE1E9F021` |

These are global Magic Mouse gestures. Their BTT trigger class is
`BTTTriggerTypeMagicMouse`, not the trackpad trigger class.

The TipTap Left trigger uses launch application action `49`, child action UUID
`B78BFD97-6D98-496B-8D15-42B6701235FF`. It calls the same background Spokenly
helper as the trackpad and MX Master.

BTT does support a dedicated Magic Mouse trigger class:

```text
BTTTriggerTypeMagicMouse
```

Useful Magic Mouse triggers observed in BTT's bundled trigger definitions:

| Gesture | Trigger type |
| --- | --- |
| 1 Finger Tap | `1` |
| 1 Finger Tap Right | `3` |
| 1 Finger Tap Above Apple | `32` |
| 1 Finger Swipe Right | `36` |
| 2 Finger Swipe Left | `5` |
| 2 Finger Swipe Right | `6` |
| 2 Finger Tap | `4` |
| 2 Finger Double-Tap | `62` |
| 3 Finger Tap | `9` |
| 3 Finger Double-Tap | `63` |
| 3 Finger Click | `21` |
| 3 Finger Swipe Left | `10` |
| 3 Finger Swipe Right | `11` |
| TipTap Left (1 Finger Fix) | `16` |
| TipTap Right (1 Finger Fix) | `17` |
| TipTap Left (2 Fingers Fix) | `30` |
| TipTap Middle (2 Fingers Fix) | `37` |
| TipTap Right (2 Fingers Fix) | `31` |

Possible future mappings:

| Goal | Candidate Magic Mouse gesture | Candidate action |
| --- | --- | --- |
| App switcher | TipTap gesture | BTT native Application Switcher |
| Enter/send alternate | 2-finger double-tap or 3-finger click | `36` / Return |

TipTap means keeping one or more fingers resting on the Magic Mouse surface and
tapping with another finger. BTT specifically notes that its special
Application Switcher mode is well suited for TipTap gestures because the
switcher can stay open while fingers remain touching the mouse or touchpad.

Caveat: BTT warns that configuring Magic Mouse two-finger swipes can block
normal Magic Mouse scrolling as soon as two fingers are touching the mouse
surface. Test Magic Mouse swipes carefully before keeping them.

## Backups

Some snapshot names retain `wispr` because they record historical
configurations. They are recovery artifacts, not active input routes.

Known-good backup from before testing the `useSpecialAppSwitcher` flag:

```text
~/.dotfiles/backups/bettertouchtool/20260630-230409-current-working-3finger-appswitcher
```

Backup from before repurposing 3-finger swipe left to `Cmd+Delete`:

```text
~/.dotfiles/backups/bettertouchtool/20260630-233931-before-left-swipe-cmd-delete
```

Backup from before adding 4-finger tap as a second Enter gesture:

```text
~/.dotfiles/backups/bettertouchtool/20260630-234325-before-4finger-tap-enter
```

Backup from before disabling 3-finger click Enter:

```text
~/.dotfiles/backups/bettertouchtool/20260630-235139-before-disabling-3finger-click-enter
```

Backup from before adding Codex-only 2-finger swipe right:

```text
~/.dotfiles/backups/bettertouchtool/20260701-203104-before-codex-2finger-swipe-right
```

Backup from before tuning 2-finger swipe sensitivity to `0.05`:

```text
~/.dotfiles/backups/bettertouchtool/20260701-203619-before-twofinger-swipe-sensitivity-005
```

Backup from before changing the Codex gesture from one-shot `Ctrl+Tab` to the
timed Control hold helper:

```text
~/.dotfiles/backups/bettertouchtool/20260701-204030-before-codex-chat-switcher-hold
```

Backup from before enabling retrigger-after-sliding on the Codex gesture:

```text
~/.dotfiles/backups/bettertouchtool/20260701-210334-before-codex-retrigger-after-sliding
```

Backup from before adding the no-touch release named trigger and distance
monitor helper:

```text
~/.dotfiles/backups/bettertouchtool/20260701-210543-before-codex-notouch-release
```

Backup from before adding Codex-only 2-finger swipe left:

```text
~/.dotfiles/backups/bettertouchtool/20260701-211730-before-codex-2finger-swipe-left
```

Backup from before simplifying the Codex gesture back to open-only behavior:

```text
~/.dotfiles/backups/bettertouchtool/20260701-212310-before-simplify-codex-chat-switcher-open-only
```

Backup from before adding lift-to-select for the Codex chat switcher:

```text
~/.dotfiles/backups/bettertouchtool/20260701-213123-before-codex-lift-to-select
```

Backup from before adding Magic Mouse Wispr/Enter gestures:

```text
~/.dotfiles/backups/bettertouchtool/20260708-095816-before-magic-mouse-wispr-enter
```

Backup from before adding Magic Mouse 2-finger swipe right app switcher:

```text
~/.dotfiles/backups/bettertouchtool/20260708-101237-before-magic-mouse-2finger-swipe-right-appswitcher
```

Backup from before moving Magic Mouse Wispr Flow to TipTap Left:

```text
~/.dotfiles/backups/bettertouchtool/20260708-103559-before-magic-mouse-wispr-tiptap-left
```

Backup from before adding Magic Mouse 1-finger tap as left click:

```text
~/.dotfiles/backups/bettertouchtool/20260709-002955-before-magic-mouse-1finger-tap-left-click
```

Backup from before adding Magic Mouse right tap and above-Apple Wispr:

```text
~/.dotfiles/backups/bettertouchtool/20260709-022252-before-magic-mouse-right-tap-and-above-apple-wispr
```

Backup from before removing Magic Mouse above-Apple Wispr:

```text
~/.dotfiles/backups/bettertouchtool/20260709-022852-before-removing-magic-mouse-above-apple-wispr
```

Backup from before moving Magic Mouse app switcher to 1-finger swipe right:

```text
~/.dotfiles/backups/bettertouchtool/20260709-024538-before-magic-mouse-1finger-swipe-right-appswitcher
```

Backup from before tuning Magic Mouse gesture sensitivity to `0.05`:

```text
~/.dotfiles/backups/bettertouchtool/20260709-025139-before-magic-mouse-sensitivity-005
```

Backup from before reverting Magic Mouse app switcher to 2-finger swipe right
and removing the Magic Mouse sensitivity override:

```text
~/.dotfiles/backups/bettertouchtool/20260709-025442-before-revert-magic-mouse-appswitcher-to-2finger
```

Backup from before scoping Magic Mouse 3-finger tap Return to Codex and making
the global action middle click:

```text
~/.dotfiles/backups/bettertouchtool/20260709-030123-before-codex-scoped-magic-mouse-3finger-enter
```

Trigger JSON from before moving the trackpad 3-finger tap from Wispr Flow to
Spokenly:

```text
~/.dotfiles/backups/bettertouchtool/20260801-before-spokenly-trackpad/trackpad-trigger-before.json
```

Trigger JSON from before moving Magic Mouse TipTap Left from Wispr Flow to
Spokenly:

```text
~/.dotfiles/backups/bettertouchtool/20260801-before-spokenly-magic-mouse/magic-mouse-trigger-before.json
```

## Troubleshooting

If the BTT gestures stop working, first check:

- BetterTouchTool is running.
- BetterTouchTool is enabled in System Settings -> Privacy & Security ->
  Accessibility.
- If requested by macOS, BetterTouchTool is also enabled under Input
  Monitoring.
- The special app switcher defaults still return `1`.
- The current trackpad trigger rows still have `ZENABLEDNEW=1` and
  `ZISENABLED=1`.

## Audit Commands

### Current Trackpad Trigger Rows

```bash
sqlite3 "$HOME/Library/Application Support/BetterTouchTool/btt_data_store.version_6_609_build_2026062603" \
  "select Z_PK, ZACTION, ZGESTURETYPE, ZISTOUCHPAD, ZSHORTCUT, ZUNIQUEIDENTIFIER, ZENABLEDNEW, ZISENABLED, ZNOTES, ZDESC from ZBTTBASEENTITY where ZISTOUCHPAD=1 order by ZGESTURETYPE, Z_PK;"
```

### Current Magic Mouse Trigger Rows

```bash
sqlite3 "$HOME/Library/Application Support/BetterTouchTool/btt_data_store.version_6_609_build_2026062603" \
  "select Z_PK, ZACTION, ZGESTURETYPE, ZISTOUCHPAD, ZSHORTCUT, ZUNIQUEIDENTIFIER, ZENABLEDNEW, ZISENABLED, ZNOTES, ZDESC from ZBTTBASEENTITY where ZUNIQUEIDENTIFIER in ('73D46814-59D7-450D-8B99-FEB4FDE8CDF1', '042FC1A5-03DD-4C9D-9424-C5D6297DABBC', '497F16E1-1725-4D6E-BD16-B8F88259EF2F', '95B221B7-9EC1-4C8A-8D15-5542228FCF02', 'CFBD7467-2660-467F-ABB4-D30CE1E9F021', 'C7595FBE-FF9E-402C-84A6-915C1EFB0D4E') order by ZGESTURETYPE;"
```

### Codex App-Specific Trigger

```bash
osascript <<'APPLESCRIPT'
tell application "BetterTouchTool"
  get_triggers trigger_app_bundle_identifier "com.openai.codex"
end tell
APPLESCRIPT
```

```bash
sqlite3 "$HOME/Library/Application Support/BetterTouchTool/btt_data_store.version_6_609_build_2026062603" \
  "select apps.ZBUNDLEIDENTIFIER, apps.ZNAME, gestures.ZGESTURETYPE, gestures.ZACTION, gestures.ZLAUNCHPATH, gestures.ZALLOWRETRIGGER, gestures.ZREPEATDELAY, gestures.ZREPEATRATE, gestures.ZUNIQUEIDENTIFIER, gestures.ZENABLEDNEW, gestures.ZISENABLED, gestures.ZDESC, gestures.ZNOTES from Z_2APPS_GESTURES rel join ZBTTBASEENTITY apps on apps.Z_PK=rel.Z_2GESTURES join ZBTTBASEENTITY gestures on gestures.Z_PK=rel.Z_9APPS_GESTURES where apps.ZBUNDLEIDENTIFIER='com.openai.codex';"
```


### Special App Switcher Defaults

```bash
defaults read com.hegenberg.BetterTouchTool useSpecialAppSwitcher
defaults read com.hegenberg.BetterTouchTool specialAppSwitcher
defaults read com.hegenberg.BetterTouchTool specialAppSwitcherInfoShown
defaults read com.hegenberg.BetterTouchTool BTTTpThreeFingerSwipeSensitivity
defaults read com.hegenberg.BetterTouchTool tpTwoFingerSwipeSensitivity
```

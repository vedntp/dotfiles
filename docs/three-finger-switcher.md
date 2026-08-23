# Three Finger Switcher

Last updated: 2026-08-22

## Status

Three Finger Switcher is a working local macOS menu-bar app that reproduces
the useful BetterTouchTool app-switching gesture without depending on
BetterTouchTool for recognition or key emission. It now owns the MacBook
trackpad's three-finger tap and horizontal swipe arbitration, so Spokenly and
the switcher cannot independently claim the same contact stream. A right swipe
opens the app switcher, while a left swipe performs one context-aware line
clear.

The source currently lives outside this dotfiles repository:

```text
/Users/vp/.codex/three-finger-switcher
```

The signed build bundle is generated at:

```text
/Users/vp/.codex/three-finger-switcher/build/Three Finger Switcher.app
```

The stable installed bundle that should actually be run is:

```text
/Applications/Three Finger Switcher.app
```

The installed app automatically creates the per-user LaunchAgent
`~/Library/LaunchAgents/com.local.ThreeFingerSwitcher.login.plist`. This is
what brings the gesture back after logout, restart, or a Software Update
reboot. The Launch at Login menu item controls this file. Running only the
temporary build bundle does not provide reliable restart persistence.

The app has bundle identifier `com.local.ThreeFingerSwitcher`. It has no
networking, accounts, telemetry, or database. It stores its small set of menu
preferences in `UserDefaults`.

Physical verification passed on 2026-08-22 after installing the directional
build. The user confirmed that the three-finger tap, right-swipe app switcher,
two-finger scrubbing, and context-aware left-swipe line clear work correctly in
normal use. The former BetterTouchTool trackpad triggers are absent from the
live BTT data store, and Spokenly's competing `threeFingerLight` mode remains
removed.

## Three-Finger Arbitration

One recognizer owns the complete three-finger contact:

- A valid tap lasts between 5 and 600 ms, every finger stays within 2.0 mm of
  its starting position, and Spokenly is toggled only after all three fingers
  release through `/Users/vp/Applications/Spokenly Toggle.app`.
- A horizontal movement that reaches the existing swipe threshold, normally
  3.5 mm at Normal sensitivity, permanently becomes a swipe. Swipe
  classification wins over tap classification once that threshold is crossed.
  The recognizer confirms the direction after 40 ms, then routes a right swipe
  to the app switcher and a left swipe to one line-clear action.
- A left swipe fires exactly once per gesture after the 3.5 mm threshold and
  40 ms confirmation. Continued movement cannot repeat it, and the action is
  re-armed only after all fingers lift.
- Contacts that move farther than the tap allowance but do not reach the swipe
  threshold are intentionally ignored. This gap prevents an accidental brush
  from toggling Spokenly.
- A fourth finger, a stale contact stream, or another cancellation condition
  produces no Spokenly action and safely cancels any active switcher session.

All three behaviors are controlled by the menu item **Enable Three-Finger Gestures**.
The line-clear action uses the cached frontmost application bundle ID, so the
context check adds negligible latency to gesture handling.
The old unnamed Spokenly `threeFingerLight` mode was backed up before removal;
Spokenly's built-in three-finger recognizer is no longer competing with this
app. To roll back, quit or disable Three Finger Switcher and restore that
backed-up `modes.v2` entry through Spokenly's settings, then re-enable its
three-finger mode.

## Current Gesture

### Right swipe, app switching

The preferred right-swipe interaction is:

1. Begin a horizontal swipe with three fingers.
2. The native macOS Command-Tab switcher opens and selects the previously used
   app.
3. Lift one finger, keeping two fingers on the trackpad.
4. Move those two fingers horizontally to scrub through the app list.
5. Lift the remaining two fingers to activate the highlighted app.

The recognizer re-anchors when contact changes from three fingers to two. This
prevents the centroid shift caused by lifting one finger from producing a
false app-switch step.

### Left swipe, line clearing

A left swipe is confirmed after 3.5 mm of horizontal movement and the existing
40 ms entry confirmation delay. It emits one shortcut based on the cached
frontmost application:

| Frontmost application | Shortcut |
| --- | --- |
| Ghostty (`com.mitchellh.ghostty`), Alacritty (`org.alacritty`), Terminal (`com.apple.Terminal`), cmux (`com.cmuxterm.app`), Warp (`dev.warp.Warp-Stable`), or iTerm2 (`com.googlecode.iterm2`) | `Ctrl+U` |
| Three Finger Switcher (`com.local.ThreeFingerSwitcher`), Finder (`com.apple.finder`), Mail (`com.apple.mail`), Messages (`com.apple.MobileSMS`), Notes (`com.apple.Notes`), Reminders (`com.apple.reminders`), Calendar (`com.apple.iCal`), or Photos (`com.apple.Photos`) | Suppressed |
| Any other, unknown, or missing bundle ID | `Cmd+Delete` |

The shortcut is posted once when the left swipe is recognized. It does not
open or alter the Command-Tab session, and it cannot repeat until the current
three-finger contact ends.

Other supported behavior:

- A quick three-finger flick still switches once and commits.
- Keeping all three fingers down still supports the original three-finger
  scrubbing behavior.
- A fourth finger cancels an active switcher with Escape and releases Command.
- A stalled touch stream is cancelled so Command cannot remain held.
- The engine probes whether the private multitouch device is still running and
  automatically re-registers it after a device stop, system wake, or screen
  wake. This prevents the menu-bar process from remaining alive with a dead
  trackpad callback.
- Two-finger scrubbing can be disabled from the menu-bar icon. Disabling it
  restores the original three-finger-only behavior without rebuilding.

## Current Calibration

The menu sensitivity controls the base three-finger distance. Two-finger
scrubbing uses `1.35` times that distance so it moves through apps more slowly.

| Menu sensitivity | Three-finger distance | Two-finger distance |
| --- | ---: | ---: |
| High | 2.5 mm | 3.375 mm |
| Normal | 3.5 mm | 4.725 mm |
| Low | 5.0 mm | 6.75 mm |

The current effective setting is Normal, so the initial gesture needs 3.5 mm
and each two-finger app step needs about 4.7 mm.

Other recognizer calibration values are in
`Sources/SwitcherCore/SwipeRecognizer.swift`:

| Variable | Value | Purpose |
| --- | ---: | --- |
| `entryDominance` | 1.5 | Initial horizontal movement must be 1.5 times the vertical movement. |
| `stepDominance` | 1.0 | Horizontal movement must exceed vertical movement while scrubbing. |
| `entryConfirmationDelay` | 40 ms | Confirms the initial swipe direction before routing the action. |
| `hudRevealDelay` | 150 ms | Lets the macOS switcher HUD appear before repeated scrub steps. |
| `twoFingerStepDistanceMultiplier` | 1.35 | Slows two-finger navigation relative to the base sensitivity. |
| `fourFingerQuarantine` | 300 ms | Prevents the tail of a four-finger system gesture from becoming a new three-finger gesture. |
| `endDebounceFrames` | 2 frames | Tolerates a momentary contact dropout before committing. |
| `staleFrameGap` | 2 seconds | Cancels a gesture after the raw touch stream stalls. |

Keyboard event timing is in
`Sources/ThreeFingerSwitcher/EventSynthesizer.swift`:

- Command is held before Tab is emitted.
- There is a 12 ms delay after Command-down so WindowServer recognizes the
  held-Command session.
- Cancellation waits 30 ms after Escape before releasing Command.
- Command-up is posted three times with 8 ms gaps to reduce the chance of a
  stuck modifier during UI animation.
- Left-swipe line-clear events use a single chord, either `Ctrl+U` or
  `Cmd+Delete`, selected from the cached frontmost bundle ID.
- A separate watchdog checks every 250 ms and cancels after a 2 second frame
  stall.

## Architecture

```text
MultitouchSupport.framework
  -> DeviceMonitor receives raw contact frames
  -> SwitcherEngine filters contacts and palms
  -> SwipeRecognizer emits begin, step, commit, clear, or cancel
  -> FrontmostApplicationCache supplies the current bundle ID for left swipes
  -> AppSwitchKeyPlanner manages the held-Command lifecycle
  -> EventSynthesizer posts Command-Tab or line-clear events through Core Graphics
```

The implementation uses Apple's private `MultitouchSupport.framework` because
public macOS APIs do not expose the required system-wide raw trackpad contacts.
This means the app is not sandboxed, is unsuitable for Mac App Store
distribution, and may need maintenance after major macOS updates.

The raw device bridge deliberately uses `MTDeviceCreateDefault()` and treats
the device as an opaque pointer. Retaining it as an Objective-C object, or
borrowing a handle from a temporary device list, caused crashes during the
macOS 27 investigation.

## Menu-Bar Controls

The arrow icon provides:

- Enable Three-Finger Gestures
- Swipe Sensitivity: High, Normal, or Low
- Two-Finger Scrubbing After Opening
- Launch at Login
- Setup Instructions
- Open Accessibility Settings
- Quit Three Finger Switcher

The relevant `UserDefaults` keys are:

| Key | Default |
| --- | --- |
| `enabled` | `true` |
| `stepDistanceMM` | `3.5` |
| `twoFingerScrubbing` | `true` |
| `onboardingShown` | Set after the first setup window |
| `launchAtLoginOptOut` | `false` |

## Build, Test, and Run

From the project root:

```sh
cd /Users/vp/.codex/three-finger-switcher
swift run SwitcherCoreChecks
./scripts/setup-signing.sh
./scripts/install-app.sh release
open "/Applications/Three Finger Switcher.app"
```

`setup-signing.sh` creates a ten-year local self-signed identity named
`Three Finger Switcher Dev` in the login Keychain. The release build uses this
stable identity so Accessibility permission survives rebuilds. If the identity
does not exist, `build-app.sh` falls back to ad-hoc signing, which can cause
macOS to treat a rebuilt app as a different Accessibility client.

`install-app.sh` builds and verifies the app, stages it in
`/Applications`, preserves the previous installed bundle as a local
backup, and replaces the stable installed copy. After an update, quit any old
running copy and open the installed app again.

First-run system setup:

1. Enable the app in System Settings > Privacy & Security > Accessibility.
2. Set System Settings > Trackpad > More Gestures > Swipe between full-screen
   applications to four fingers. This avoids a collision with the custom
   three-finger gesture.

The old equivalent BetterTouchTool three-finger app-switcher triggers must stay
disabled while this app is running. Otherwise BTT can race the recognizer for
the same trackpad contacts. This project does not automatically delete or
modify any unrelated BetterTouchTool trigger.

## Rollback and Recovery

To reject only the experimental two-finger interaction, turn off **Two-Finger
Scrubbing After Opening** in the menu. The original working three-finger path
remains intact.

To disable the entire custom gesture, turn off **Enable Three-Finger Gestures**
or quit the menu-bar app. BetterTouchTool can then own the gesture again if its
corresponding triggers are enabled. The old BTT left-swipe trigger always sends
`Cmd+Delete`; enable it only if that static rollback behavior is wanted. To
restore Spokenly's original ownership of the three-finger tap, restore the
backed-up unnamed `threeFingerLight` mode in Spokenly after disabling this app.

If the switcher ever appears stuck, lift all fingers. The recognizer commits on
release, and the independent watchdog cancels a stalled session after 2
seconds. Quitting the menu-bar app also sends a cancellation and releases
Command.

If a rebuild stops sending Command-Tab:

1. Confirm that the bundle is signed by `Three Finger Switcher Dev` with
   `codesign -dv --verbose=4 "/Applications/Three Finger Switcher.app"`.
2. Confirm Accessibility permission for the exact installed app bundle.
3. Quit and reopen the app after changing permission.
4. Run `swift run SwitcherCoreChecks` to separate recognizer problems from
   permission or event-posting problems.

## Project File Inventory

All paths below are relative to
`/Users/vp/.codex/three-finger-switcher`.

| File | Purpose |
| --- | --- |
| `.gitignore` | Excludes Swift and packaged build output. |
| `App/Info.plist` | App identity, version, menu-bar-only mode, and minimum macOS version. |
| `Package.swift` | Swift package targets, products, platform, and private-framework linker settings. |
| `README.md` | Project-level behavior, build, setup, and architecture overview. |
| `LICENSE` | Project license. |
| `NOTICE.md` | Attribution for the Trident-informed implementation. |
| `Sources/SwitcherCore/SwipeRecognizer.swift` | Three-finger detection, two-finger phase, thresholds, debounce, cancellation, and emitted actions. |
| `Sources/SwitcherCore/AppSwitchKeyPlanner.swift` | Pure state machine for Command-down, Tab, Escape, and Command-up. |
| `Sources/SwitcherCoreChecks/main.swift` | Executable regression checks for flicks, scrubbing, fallback, cancellation, and key lifecycle. |
| `Sources/ThreeFingerSwitcher/ThreeFingerSwitcherMain.swift` | Application entry point. |
| `Sources/ThreeFingerSwitcher/AppDelegate.swift` | Menu-bar UI, persisted settings, Accessibility onboarding, and launch-at-login control. |
| `Sources/ThreeFingerSwitcher/MultitouchSupport.swift` | Private framework declarations and the raw `MTTouch` binary layout. |
| `Sources/ThreeFingerSwitcher/DeviceMonitor.swift` | Trackpad discovery, surface measurement, callback registration, and raw frame delivery. |
| `Sources/ThreeFingerSwitcher/SwitcherEngine.swift` | Thread-safe wiring, active-contact extraction, and palm filtering. |
| `Sources/ThreeFingerSwitcher/EventSynthesizer.swift` | Core Graphics keyboard posting and the stuck-gesture watchdog. |
| `scripts/setup-signing.sh` | Creates the stable local signing identity. |
| `scripts/signing-cert.cnf` | OpenSSL configuration for that identity. |
| `scripts/build-app.sh` | Builds, packages, signs, and verifies the `.app` bundle. |
| `scripts/install-app.sh` | Builds and installs the signed bundle at the stable user Applications path. |

Generated files are not source files:

- `.build/` is Swift Package Manager output.
- `build/Three Finger Switcher.app/` is the signed runnable bundle.
- `/Applications/Three Finger Switcher.app/` is the stable installed
  copy used for Accessibility and Launch at Login.
- The `Three Finger Switcher Dev` certificate and private key live in the
  macOS Keychain, not in either repository.

## Origin and Future Work

The project began as a local replacement for the BetterTouchTool three-finger
Application Switcher behavior after reviewing the
[Can I Vibe Code It article](https://canivibecodeit.com/bettertouchtool). The
raw touch bridge and held-Command interaction were informed by the
MIT-licensed [Trident project](https://github.com/cyanyux/trident), with local
gesture recognition, menu controls, safety handling, tests, signing, and the
three-to-two-finger interaction built around it.

Possible future improvements:

- Give two-finger scrubbing its own menu sensitivity instead of a fixed
  multiplier.
- Publish the full source project to a dedicated repository on the user's own GitHub account later.
- Add structured runtime diagnostics to the menu.
- Recheck the private touch structure and callbacks after major macOS updates.

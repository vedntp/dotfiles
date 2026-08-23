# Custom Shortcut Reference

Last audited against live settings: 2026-08-22

## Purpose

This is the quick reference for custom inputs managed through Logitech
Options+, BetterTouchTool, and Spokenly. It records what a physical input does
now. Use the detailed setup guides for implementation history, database fields,
backup procedures, and troubleshooting:

- [Logitech Options+ and Spokenly setup](logitech-options-spokenly.md)
- [MX Master 3S reconstruction manifest](logitech-mx-master-3s-shortcuts.json)
- [BetterTouchTool gesture setup](btt/README.md)
- [Spokenly transcription profile](transcription/spokenly/README.md)
- [Three Finger Switcher](three-finger-switcher.md)
- [Ducky One 2 macOS setup](ducky-one-2-setup.md)

Live application settings are authoritative when this file and a detailed guide
disagree.

## Logitech MX Master 3S

### Shared gesture button

The gesture/top button (`c196`) uses Logitech's Application Navigation card in
all current profiles.

| Physical input | Result |
| --- | --- |
| Click | Launchpad |
| Hold and move up | Mission Control |
| Hold and move down | App Expose |
| Hold and move left or right | Switch applications |

### Application profiles

The Logitech profile displayed as `ChatGPT` targets Codex bundle ID
`com.openai.codex`.

| Profile | Auxiliary/thumb `c195` | Wheel click `c82` | Back `c83` | Forward `c86` | Thumb wheel up / left | Thumb wheel down / right |
| --- | --- | --- | --- | --- | --- | --- |
| Desktop/default | Logitech Smart Action `Spokenly Hands-Free` | Middle click | Native Back | Native Forward | Native horizontal scroll | Native horizontal scroll |
| Alacritty (`org.alacritty`) | Logitech Smart Action `Spokenly Hands-Free` | Return | `Ctrl+U` | `Ctrl+Tab`, next tab | `Ctrl+Option+Shift+Tab` (raw) | `Ctrl+Option+Tab` (raw) |
| Codex, shown as ChatGPT (`com.openai.codex`) | Logitech Smart Action `Spokenly Hands-Free` | Return | `Cmd+Delete` | `Shift+Return` | `Ctrl+Tab` | `Cmd+K`, open search |
| Conductor (`com.conductor.app`) | Logitech Smart Action `Spokenly Hands-Free` | Return | `Cmd+Delete` | `Shift+Return` | `Ctrl+Shift+Tab` | `Ctrl+Tab` |
| Claude (`com.anthropic.claudefordesktop`) | Logitech Smart Action `Spokenly Hands-Free` | Enter | Native Back | Native Forward | `Ctrl+Shift+Tab` | `Ctrl+Tab` |
| Ghostty (`com.mitchellh.ghostty`) | Logitech Smart Action `Spokenly Hands-Free` | Enter | Native Back | Native Forward | `Ctrl+Shift+Tab` | `Ctrl+Tab` |
| Safari (`com.apple.Safari`) | Logitech Smart Action `Spokenly Hands-Free` | Middle click | Native Back | Native Forward | `Ctrl+Shift+Tab` | `Ctrl+Tab` |
| Google Chrome (`com.google.Chrome`) | Logitech Smart Action `Spokenly Hands-Free` | Middle click | Native Back | Native Forward | `Ctrl+Shift+Tab` | `Ctrl+Tab` |
| Brave Browser (`com.brave.Browser`) | Logitech Smart Action `Spokenly Hands-Free` | Middle click | Native Back | Native Forward | `Ctrl+Shift+Tab` | `Ctrl+Tab` |
| Firefox (`org.mozilla.firefox`) | Logitech Smart Action `Spokenly Hands-Free` | Middle click | Native Back | Native Forward | `Ctrl+Shift+Tab` | `Ctrl+Tab` |
| Helium (`net.imput.helium`) | Logitech Smart Action `Spokenly Hands-Free` | Middle click | Native Back | Native Forward | `Ctrl+Tab` | `Ctrl+Shift+Tab` |
| Sioyek (`info.sioyek.sioyek`) | Logitech Smart Action `Spokenly Hands-Free` | Middle click | Right Arrow | Left Arrow | `-`, zoom out | `=`, zoom in |

## BetterTouchTool

### Global keyboard sequences

| Physical input | Result |
| --- | --- |
| Triple F4, no more than 0.35 seconds between events | Lock the screen using BTT's native Lock Screen action |

### Native MacBook keyboard listener

| Physical input | App scope | Owner | Result |
| --- | --- | --- | --- |
| Standalone Globe/Fn tap, no more than 0.35 seconds | Ghostty or Alacritty | `macbook-fn-herdr-listener` LaunchAgent | Sends `Ctrl+B`, the Herdr prefix |

The listener reads explicit down/up values from the built-in keyboard's raw
IOHID Fn element, then uses a listen-only event tap to detect other keys,
modifiers, and media-key activity. It leaves all physical input unchanged and
sends the prefix only when Ghostty or Alacritty is frontmost at press and
release and no other input participates. The former BTT trigger
`3D18BB81-90D9-4CD9-BED3-9B46FBB2F683` is disabled and preserved solely for
rollback.

The working deployment requires the compiled binary at
`~/Library/Caches/dotfiles/macbook-fn-herdr-listener` to be enabled in both
Input Monitoring and Device Control and Data Access. The quick-tap path was
physically verified in Ghostty on 2026-08-15 and in Alacritty on 2026-08-16.
The live Alacritty test produced exactly one `Ctrl+B`, with the listener log
showing `allowedTerminal=true` and one `Fn tap triggered Ctrl+B` entry.

### Global MacBook trackpad gestures

| Physical input | Result |
| --- | --- |
| 3-finger tap | Three Finger Switcher waits for release, then opens `Spokenly Toggle.app` |
| 3-finger swipe right | Three Finger Switcher opens the macOS app switcher and supports two-finger scrubbing |
| 3-finger swipe left | After 3.5 mm and 40 ms confirmation, sends one context-aware line-clear shortcut |
| 4-finger tap | Return |

Three Finger Switcher owns both three-finger tap and horizontal swipe
classification. A tap must last 5 to 600 ms with no more than 2.0 mm of
per-finger travel. Once the existing swipe threshold is crossed, swipe wins and
Spokenly is not toggled. A left swipe uses the cached frontmost application:
`Ctrl+U` in Ghostty, Alacritty, Terminal, cmux, Warp, and iTerm2, no shortcut
in Three Finger Switcher, Finder, Mail, Messages, Notes, Reminders, Calendar,
or Photos, and `Cmd+Delete` in every other, unknown, or missing-bundle app.
The left action fires once per gesture and is re-armed after all fingers lift.
The cache lookup adds negligible latency. All three-finger behaviors are
controlled by **Enable Three-Finger Gestures**.

Physical verification passed on 2026-08-22. The user confirmed that tap,
right-swipe app switching with two-finger scrubbing, and context-aware
left-swipe clearing work correctly in normal use. The superseded BTT trackpad
triggers are absent from the live BTT data store.

### Global Magic Mouse gestures

| Physical input | Result |
| --- | --- |
| 1-finger tap | Left click at the pointer |
| 1-finger tap right | Right click at the pointer |
| 2-finger swipe right | Open BTT's Application Switcher |
| 3-finger tap | Middle click at the pointer |

### Application-specific BTT shortcuts

Application-specific triggers override matching global gestures.

| Application | Input | Result |
| --- | --- | --- |
| Codex | Trackpad 2-finger swipe right | Open the Codex chat switcher, then select the hovered chat when the final finger lifts |
| Codex | Magic Mouse 3-finger tap | Return instead of the global middle click |
| Codex | `Ctrl+B` | Toggle the sidebar between `By project` and `In one list` through the debounced helper |
| Codex | Normal-mouse horizontal scroll right | Toggle the sidebar between `By project` and `In one list` through the direct helper |
| YouTube Brave app | `Cmd+Shift+C` | Open the application menu and run its native Copy URL command |

### Spokenly keyboard shortcut

| Input | Result |
| --- | --- |
| MacBook physical Right Option | Activates Spokenly's Default Mode directly |
| Ducky physical right GUI, immediately right of right Alt | Emits Right Option and activates the same Default Mode directly |

The MX Master auxiliary/thumb button uses Logitech's `Spokenly Hands-Free`
Smart Action to open `Spokenly Toggle.app`, which calls `spokenly://toggle`.
The MacBook trackpad three-finger tap also reaches Spokenly through that helper,
but only after Three Finger Switcher classifies and releases a valid tap. The
unnamed Spokenly `threeFingerLight` mode was backed up and deleted so it cannot
race the switcher. Magic Mouse activation remains governed by its current BTT
configuration.

The complete machine-readable profile inventory, including Logitech card
payloads and thumb-wheel directions, is in the [MX Master 3S reconstruction
manifest](logitech-mx-master-3s-shortcuts.json).

## Spokenly

Spokenly `2.27.16` (`538`) uses its direct Right Option shortcut with
automatic activation. The live preference serializes it as `rawFlags: 64`,
`activationMode: "automatic"`, and `modeMac: "autoInsert"`.

| Input | Result | Origin |
| --- | --- | --- |
| MacBook physical Right Option | Activates the Default Mode | Direct Spokenly shortcut |
| Ducky physical right GUI, immediately right of right Alt | Emits Right Option and activates the Default Mode | Native Ducky modifier mapping, then the direct Spokenly shortcut |
| MX Master auxiliary/thumb button | Opens the helper and toggles Spokenly | Logitech Smart Action |

See the [Spokenly input profile](transcription/spokenly/README.md) for live
settings, device compatibility, automation hooks, and verification.

## Ducky modifier mapping

The Ducky One 2 Command, Option, and Caps mappings are owned by native macOS in
`com.apple.keyboard.modifiermapping.1241-661-0`. Physical right Alt remains
Right Command, while physical right GUI emits Right Option.

## Herdr

The live sources are `mac/.config/herdr/config.toml` and
`mac/.config/alacritty/alacritty.toml`. Herdr's prefix remains `Ctrl+B`, and
the prefix alternatives remain available. Alacritty forwards the Command
chords with `ReceiveChar`; the workspace shortcuts depend on Option-as-Alt.

| Shortcut | Result |
| --- | --- |
| `Ctrl+B`, then `n` / `p` | Next / previous Herdr tab |
| `Ctrl+PageDown` / `Ctrl+PageUp` | Next / previous Herdr workspace (translated by Alacritty to Herdr prefix + `Shift+N` / `Shift+P`) |
| `Cmd+1` through `Cmd+9` | Switch to Herdr workspaces 1 through 9 |
| `Ctrl+Option+1` through `Ctrl+Option+9` | Focus agents 1 through 9 |
| `Option+Tab` / `Option+Shift+Tab` | Next / previous Herdr agent |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next / previous Herdr tab; Ctrl+Tab is also the MX Master Forward-button mapping in Alacritty |
| `Ctrl+1` through `Ctrl+9` | Switch directly to Herdr tabs 1 through 9 |
| `Cmd+T` | Open a new Herdr tab immediately with a generated name |
| `Cmd+Shift+T` | Rename the focused Herdr tab |
| `Cmd+W` | Close the focused Herdr pane, not the tab |
| `Cmd+D` / `Cmd+Shift+D` | Split vertically / horizontally |
| `Cmd+Z` | Toggle zoom for the focused Herdr pane |
| `Cmd+Shift+H` / `Cmd+Shift+J` / `Cmd+Shift+K` / `Cmd+Shift+L` | Focus the pane left / down / up / right |
| `Cmd+P` | Open the Herdr Goto navigator |

The MX Master thumb wheel still emits the raw Ctrl+Option+Shift+Tab and
Ctrl+Option+Tab chords in Alacritty, but Herdr has no custom action for those
thumb-wheel chords.

Stock Alacritty/winit retains the native `Hide Alacritty` Cmd+H menu action;
Cmd+Shift+H is the Herdr pane-left shortcut. Cmd+K remains Alacritty's native
Clear History action.

## Maintenance

Update this file whenever a Logitech Options+ profile, BetterTouchTool trigger,
or Spokenly shortcut changes. Record current behavior here, and keep
implementation history and troubleshooting detail in the specialized guides.

Audit the live sources before editing this reference:

- Logitech Options+: `~/Library/Application Support/LogiOptionsPlus/settings.db`
- BetterTouchTool: BTT's `get_triggers` AppleScript command
- Spokenly: `~/Library/Preferences/app.spokenly.plist`

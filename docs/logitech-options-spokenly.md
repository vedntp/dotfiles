# Logitech Options+ and Spokenly Setup

Last audited: 2026-09-03

## Goal

Keep the MX Master 3S controls predictable across Codex, AI apps, terminals,
browsers, and Spokenly.

The important split:

- Chat and terminal-like apps, including Codex: wheel click sends `Enter`.
- Browsers: wheel click stays a real middle click.
- The auxiliary/thumb button opens `Spokenly Toggle.app` in every restored
  profile, including Desktop/default.

## Source of Truth

Logitech Options+ stores its profile state in:

```text
~/Library/Application Support/LogiOptionsPlus/settings.db
```

The real settings are stored as one JSON blob in SQLite table `data`, column
`file`.

The companion Smart Action definition is stored in:

```text
~/Library/Application Support/LogiOptionsPlus/macros.db
```

## MX Master 3S Slot IDs

Observed device prefix:

```text
mx-master-3s-2b034
```

Useful slots:

| Slot | Physical control | Notes |
| --- | --- | --- |
| `mx-master-3s-2b034_c82` | Wheel click / middle button | `Enter` in terminal-like apps and Codex, `MB3` in browsers. |
| `mx-master-3s-2b034_c83` | Back button | Native Back in browsers/default; `Cmd+Delete` in Codex. |
| `mx-master-3s-2b034_c86` | Forward button | Native Forward in browsers/default; `Shift+Return` in Codex. |
| `mx-master-3s-2b034_c195` | Aux/thumb-style button | Smart Action `Spokenly Hands-Free`, which opens `Spokenly Toggle.app`. |
| `mx-master-3s-2b034_c196` | Gesture/top button | App navigation gesture card. |

The documented HID key codes and modifier arrays are preserved in the
[machine-readable MX Master 3S manifest](logitech-mx-master-3s-shortcuts.json).
The manifest also records the exact Smart Action card, helper path, profile IDs,
application IDs, and both thumb-wheel directions.

## Current Logitech Profile Benchmark

### Full Profile Snapshot

Generated from the live Logitech Options+ database and rechecked on 2026-09-03.

| App/profile | Bundle id | Thumb button `c195` | Wheel click `c82` | Back `c83` | Forward `c86` |
| --- | --- | --- | --- | --- | --- |
| Desktop/default | global fallback | Smart Action `Spokenly Hands-Free` | Real middle click: `MB3` | `Cmd+Delete` | `Shift+Return` |
| Codex | `com.openai.codex` | Smart Action `Spokenly Hands-Free` | `Enter` | `Cmd+Delete` | `Shift+Return` |
| Conductor | `com.conductor.app` | Smart Action `Spokenly Hands-Free` | `Enter` | `Cmd+Delete` | `Shift+Return` |
| Claude | `com.anthropic.claudefordesktop` | Smart Action `Spokenly Hands-Free` | `Enter` | Native Back | Native Forward |
| Ghostty | `com.mitchellh.ghostty` | Smart Action `Spokenly Hands-Free` | `Enter` | Native Back | Native Forward |
| Alacritty | `org.alacritty` | Smart Action `Spokenly Hands-Free` | `Enter` | `Ctrl+U` | `Ctrl+PageDown` |
| Safari | `com.apple.Safari` | Smart Action `Spokenly Hands-Free` | Real middle click: `MB3` | Native Back | Native Forward |
| Google Chrome | `com.google.Chrome` | Smart Action `Spokenly Hands-Free` | Real middle click: `MB3` | Native Back | Native Forward |
| Brave Browser | `com.brave.Browser` | Smart Action `Spokenly Hands-Free` | Real middle click: `MB3` | Native Back | Native Forward |
| Firefox | `org.mozilla.firefox` | Smart Action `Spokenly Hands-Free` | Real middle click: `MB3` | Native Back | Native Forward |
| Helium | `net.imput.helium` | Smart Action `Spokenly Hands-Free` | Real middle click: `MB3` | Native Back | Native Forward |
| Sioyek | `info.sioyek.sioyek` | Smart Action `Spokenly Hands-Free` | Real middle click: `MB3` | Right Arrow | Left Arrow |
| youtube | `com.brave.Browser.app.agimnkijcaahngcdmfeangaknmldooml` | Smart Action `Spokenly Hands-Free` | Real middle click: `MB3` | Native Back | Native Forward |

### Alacritty Herdr Navigation

The Alacritty application profile targets bundle ID `org.alacritty` and uses
explicit keyboard shortcuts:

| Physical control | Assignment |
| --- | --- |
| Back button | `Ctrl+U` |
| Forward button | `Ctrl+PageDown`, next Herdr workspace via Alacritty translation |
| Thumb wheel up / left | `Ctrl+Shift+Tab`, previous Herdr tab |
| Thumb wheel down / right | `Ctrl+Tab`, next Herdr tab |

Herdr maps `Ctrl+Tab` / `Ctrl+Shift+Tab` to next / previous tab, and Alacritty
translates the Forward-button `Ctrl+PageDown` chord to Herdr prefix +
`Shift+N` for next workspace. The previous raw `Ctrl+Option+Tab` thumb-wheel
chords are gone.

### Wheel Click

| App/profile | Bundle id | Wheel click |
| --- | --- | --- |
| Codex | `com.openai.codex` | `Enter` key |
| Conductor | `com.conductor.app` | `Enter` key |
| Claude | `com.anthropic.claudefordesktop` | `Enter` key |
| Ghostty | `com.mitchellh.ghostty` | `Enter` key |
| Alacritty | `org.alacritty` | `Enter` key |
| Desktop/default | global fallback | Real middle click: `MB3` |
| Safari | `com.apple.Safari` | Real middle click: `MB3` |
| Google Chrome | `com.google.Chrome` | Real middle click: `MB3` |
| Brave Browser | `com.brave.Browser` | Real middle click: `MB3` |
| Firefox | `org.mozilla.firefox` | Real middle click: `MB3` |
| Helium | `net.imput.helium` | Real middle click: `MB3` |

Use `Enter` for apps where wheel click means "send/submit current composer"
and a real middle click would steal focus.

Use `MB3` for browsers because middle click opens links in background tabs and
does browser-native tab behavior.

### Back / Forward

Known-good browser/default shape:

| Slot | Expected action |
| --- | --- |
| `c83` | `OSX_GESTURE_BACK` |
| `c86` | `OSX_GESTURE_FORWARD` |

Profiles currently matching that browser/default shape:

- Safari
- Google Chrome
- Brave Browser
- Firefox
- Helium
- Claude
- Ghostty
- youtube Brave PWA

Desktop/default no longer matches. It now uses `Cmd+Delete` and
`Shift+Return`, the same as Codex and Conductor.

Every restored MX Master profile assigns the thumb button (`c195`) to the
Logitech Smart Action `Spokenly Hands-Free`, which opens
`~/Applications/Spokenly Toggle.app`.

The Smart Action card identifier is
`d18fe790-d754-4fbc-8e82-0e5df78bda9e`; its macro payload opens
`/Users/vp/Applications/Spokenly Toggle.app` with the `OPEN_FILE_FOLDER`
action. The thirteen profile IDs, application IDs, application paths, HID key
codes, and modifier arrays are preserved in the [reconstruction manifest](logitech-mx-master-3s-shortcuts.json).

Codex currently has a custom layout:

| Slot | Current Codex assignment |
| --- | --- |
| `c195` | Smart Action `Spokenly Hands-Free`; opens `Spokenly Toggle.app`, then `spokenly://toggle` |
| `c82` | `Enter` / `Return` |
| `c83` | `Cmd+Delete` (`code: 42`, modifiers `[227]`) |
| `c86` | `Shift+Return` (`code: 40`, modifiers `[225]`) |
| Thumb wheel left | `Ctrl+Tab` (`code: 43`, modifiers `[224]`) |
| Thumb wheel right | `Cmd+K` (`code: 14`, modifiers `[227]`) |

Treat Codex side buttons separately from browser side buttons.

### Codex ChatGPT Profile

The Logitech Options+ application profile is displayed as `ChatGPT`, but it
targets the Codex application:

```text
Application: /Applications/ChatGPT.app
Bundle ID: com.openai.codex
```

The current known-good assignments are:

| Physical control | Assignment |
| --- | --- |
| Auxiliary/thumb button | Logitech Smart Action `Spokenly Hands-Free` |
| Wheel click | `Return` (`code: 40`) |
| Back button | `Cmd+Delete` (`code: 42`, modifiers `[227]`) |
| Forward button | `Shift+Return` (`code: 40`, modifiers `[225]`) |
| Thumb wheel left | `Ctrl+Tab` (`code: 43`, modifiers `[224]`) |
| Thumb wheel right | `Cmd+K` (`code: 14`, modifiers `[227]`) |

The Codex-specific BetterTouchTool `Ctrl+B` sidebar trigger remains available,
but the restored Logitech profile does not assign `Ctrl+B` to a mouse control.

The Logitech settings database was backed up before repairing these
assignments:

```text
~/Library/Application Support/LogiOptionsPlus/settings.db.backup-codex-20260728
```

The current known-good recovery snapshot used for the August audit is:

```text
~/Library/Application Support/LogiOptionsPlus/settings.db.recovered-full-with-global-20260819-144026
SHA-256: a578b4ffd9a5e5cbcea24e4828eb582109ec835309b4acce5e965e4a3060ffe9
```

The September audit is against the live database directly. The manifest
`audit_timestamp` is `2026-09-03` and `expected_profile_count` is `13`.

See the related BTT guide for trigger details and troubleshooting:

[Codex sidebar organization shortcut](btt/README.md#codex-sidebar-organization-shortcut)

## Related BetterTouchTool Docs

BetterTouchTool trackpad gestures and future Magic Mouse experiments are
documented separately:

[BetterTouchTool gesture setup](btt/README.md)

## Input Ownership

- Browser wheel click remains native `MB3`.
- Chat and terminal wheel click sends `Enter` directly from Logitech Options+.
- The MX Master auxiliary/thumb button uses Logitech's `Spokenly Hands-Free`
  Smart Action.
- BetterTouchTool does not own the MX Master Spokenly route.

### Codex And Browser Focus

Codex uses a plain `Enter` keystroke for wheel click. No mouse click reaches
Codex first, so focus is not moved before the send action.

Browser profiles keep wheel click as real `MB3`, preserving background-tab and
other browser-native middle-click behavior.

### YouTube PWA / Brave App

YouTube installed from Brave runs as a separate app shim:

```text
/Users/vp/Applications/Brave Browser Apps.localized/YouTube.app
com.brave.Browser.app.agimnkijcaahngcdmfeangaknmldooml
```

It now has a dedicated Logi profile named `youtube`, so it no longer falls
back to Desktop/default:

- Wheel click: `MB3`
- Back: Native Back
- Forward: Native Forward
- Thumb wheel: system volume control

### Helium Thumb Wheel

Helium thumb wheel was swapped to left equals previous and right equals next:

- Thumb wheel up / left: `Ctrl+Shift+Tab`, previous tab
- Thumb wheel down / right: `Ctrl+Tab`, next tab

This matches the Alacritty Herdr tab direction and fixes the previous reversed
mapping.

In this setup, the default profile now keeps:

- Wheel click: `MB3`
- Back: `Cmd+Delete`
- Forward: `Shift+Return`

## Audit Commands

### Read-only manifest audit

The dependency-free audit utility opens `settings.db` with SQLite URI
`mode=ro`. It reports missing, additional, or mismatched profiles and controls,
and exits nonzero for drift. It never repairs or writes Logitech state.

```bash
python3 scripts/audit-logitech-shortcuts.py
```

Override the source paths when auditing a recovery copy:

```bash
python3 scripts/audit-logitech-shortcuts.py \
  --manifest docs/logitech-mx-master-3s-shortcuts.json \
  --database "$HOME/Library/Application Support/LogiOptionsPlus/settings.db"
```

See the [MX Master 3S reconstruction manifest](logitech-mx-master-3s-shortcuts.json)
for the versioned profile inventory and exact relevant Logitech card payloads.

### Logitech Profile Summary

```bash
python3 - <<'PY'
import json, os, sqlite3

db = os.path.expanduser('~/Library/Application Support/LogiOptionsPlus/settings.db')
root = json.loads(sqlite3.connect(db).execute('select file from data limit 1').fetchone()[0])
apps = {a.get('applicationId'): a for a in root.get('applications', {}).get('applications', [])}

for pid in root.get('profile_keys', []):
    prof = root[pid]
    app = apps.get(prof.get('applicationId'), {})
    name = app.get('name') or prof.get('applicationId')
    bundle = app.get('bundleId') or ''
    print(f'\n{name}\t{bundle}\t{pid}')

    for slot in [
        'mx-master-3s-2b034_c82',
        'mx-master-3s-2b034_c83',
        'mx-master-3s-2b034_c86',
        'mx-master-3s-2b034_c195',
        'mx-master-3s-2b034_c196',
    ]:
        assignment = next((a for a in prof.get('assignments', []) if a.get('slotId') == slot), None)
        if not assignment:
            continue
        card = assignment.get('card', {})
        print(slot, card.get('id'), card.get('macro', {}))
PY
```

## Safe Editing Notes

Before editing Logitech settings manually:

1. Back up the database.
2. Quit Logi Options+ and stop its launch agent.
3. Patch the JSON blob in SQLite.
4. Run SQLite integrity check.
5. Restart Logi Options+.
6. Re-audit after restart because Logi can overwrite direct edits from memory.

Example backup path used during debugging:

```text
work/logi-backups/
```

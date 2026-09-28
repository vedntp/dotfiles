# Web Apps (Chrome and Brave PWAs)

Last updated: 2026-09-14

How site-specific web apps are set up on this Mac, what the preferences are,
which apps exist, and the gotchas learned the hard way.

## Preferences

- **Browser: Chrome** for new web apps. Sites "just work" there. Helium breaks
  too many sites. Safari (`File > Add to Dock`) is not wanted.
- **One Chrome profile per app**, named after the app (`Gmail`, `Muse`, ...).
  The app must not share history, cookies, or logins with the everyday Chrome
  profile (`Chatgpt`).
- **Proper macOS identity**: the app's own name and icon in Cmd+Tab, the Dock,
  and Spotlight. The icon should be the real product logo, not the generic
  manifest icon a site happens to ship.
- **Minimal data to Google**: never sign in to Chrome itself in an app profile.
  Sign in only on the website.
- Older apps (YouTube, YouTube Music, Grok) live in Brave and are left there.

## Creating a new web app

1. Chrome > profile icon > **Add** > **Continue without an account**. Name the
   profile after the app and pick a colour.
2. In the new profile, **Settings > You and Google > Sync and Google services**,
   turn off:
   - Allow Chrome sign-in
   - Autocomplete searches and URLs
   - Make searches and browsing better
   - Help improve Chrome's features and performance
3. **Settings > Privacy and security > Ad privacy**: turn off Ad topics,
   Site-suggested ads, and Ad measurement. Block third-party cookies. Keep Safe
   Browsing on Standard.
4. Open the site, sign in on the site only.
5. **⋮ > Cast, save and share > Install page as app**.
6. If the icon is wrong, fix it with `webapp-icon set` (below).
7. Add the app to the inventory table in this file. If it needs a workspace,
   add an `[[on-window-detected]]` rule by bundle id in
   `mac/.config/aerospace/aerospace.toml` (above the catch-all).

The app shim is created at `~/Applications/Chrome Apps.localized/<Name>.app`
with bundle id `com.google.Chrome.app.<app-id>`. The app id is derived from the
site's manifest id, so reinstalling the same site gives the same bundle id.

## Inventory

| App | Browser | Profile (dir) | Bundle id | Start URL | Custom icon |
|-----|---------|---------------|-----------|-----------|-------------|
| Gmail | Chrome | `Gmail` (`Profile 2`) | `com.google.Chrome.app.fmgjjmmmlfnkbppncabfkddbjimcfncm` | `https://mail.google.com/mail/?usp=installed_webapp` | no |
| Muse | Chrome | `Muse` (`Profile 3`) | `com.google.Chrome.app.hichoggbhebpgpgcbcgfpkjmohpcflhh` | `https://muse.ai/?__pwa=1` | yes, `mac/.config/webapp-icons/Muse*.png` |
| YouTube | Brave | `YouTube` (`Default`) | `com.brave.Browser.app.agimnkijcaahngcdmfeangaknmldooml` | `https://www.youtube.com/?feature=ytca` | no |
| YouTube Music | Brave | `YouTube` (`Default`) | `com.brave.Browser.app.cinhimbnkkaeohfgghhklpknlkffjgod` | `https://music.youtube.com/?source=pwa` | no |
| Grok | Brave | `Brave-Main` (`Profile 3`) | `com.brave.Browser.app.ggjocahimgaohmigbfhghnlfcnjemagj` | `https://grok.com/` | no |

Everyday Chrome profile: `Chatgpt` (`Default`). No Chrome profile is signed in
to Chrome sync.

Regenerate the raw data:

```bash
for a in ~/Applications/*Apps.localized/*.app(N); do
  p="$a/Contents/Info.plist"
  print "$(plutil -extract CFBundleName raw $p) | $(plutil -extract CFBundleIdentifier raw $p) | $(plutil -extract CrAppModeShortcutURL raw $p)"
done
grep -l <app-id> ~/Library/Application\ Support/Google/Chrome/*/Preferences   # owning profile
```

## Custom icons: `webapp-icon`

`mac/.local/bin/webapp-icon` (linked into `~/.local/bin`). Source icons live in
`mac/.config/webapp-icons/` (linked to `~/.config/webapp-icons`) as
`<App name>.png` and `<App name>-maskable.png`.

```bash
webapp-icon set Muse ~/.config/webapp-icons/Muse.png ~/.config/webapp-icons/Muse-maskable.png
webapp-icon sync    # reapply any saved icon that the browser reverted
```

- `icon`: 1024px macOS-style tile (rounded square, transparent margin).
- `maskable`: 1024px full-bleed square, logo within the central ~60%.
- Rewrites every stored icon for the app, patches and re-signs the shim, and
  keeps backups in `~/Library/Application Support/webapp-icon/backups/`.
  Works for Chrome and Brave apps. Quitting the browser first is safest.
- No background job. A LaunchAgent version was built and removed on
  2026-09-15: the user does not want anything running in the background, and
  launchd jobs cannot read browser profile data without Full Disk Access. If
  an icon reverts, run `webapp-icon sync` by hand.

Why it has to be this involved:

- Editing only `<App>.app/Contents/Resources/app.icns` gets reverted. Chrome
  validates the ad-hoc signed shim and rebuilds it on launch.
- Chrome rebuilds the shim from
  `<profile>/Web Applications/Manifest Resources/<app-id>/`, which has
  `Icons/`, `Icons Maskable/`, and **`Trusted Icons/Icons Maskable/`**. The macOS
  shim is built from the trusted maskable set. Missing that folder is what made
  the Muse icon revert twice.
- Chrome's manifest update check can still pull the site's own icons back.
  Decline any "update app icon" prompt.

Making an icon from a site's logo: the official Muse mark is
`https://muse.ai/landing/brand/muse-logo.svg` (saved as
`mac/.config/webapp-icons/Muse-logo.svg`). Render with `rsvg-convert` and
compose the tile/maskable PNGs (Pillow via `uv run`).

## Gotchas and history

- **Do not use `--user-data-dir` launchers.** The first Gmail app (2026-09-14)
  was an AppleScript applet running
  `Google Chrome --user-data-dir=~/Library/Application Support/GmailChrome --app=...`.
  Problems:
  - Cmd+Tab and the Dock showed "Google Chrome", not Gmail.
  - Every click opened another window.
  - Worst: while it was running, clicking the normal Chrome icon made macOS
    reuse that process (same `com.google.Chrome` bundle id), so a normal
    looking Chrome window opened in the Gmail data dir. Clearing history there
    wiped the Gmail profile. Removed and replaced with a Chrome profile + PWA.
- **Clear browsing data from the right profile.** Check the profile avatar in
  the window before using Delete browsing data. It only affects that profile.
- **Last used profile**: Chrome may open the last used profile (possibly an app
  profile) when clicked. Enable "Show on startup" in the profile picker if that
  becomes annoying.
- **Chrome's CDP `PWA.*` domain is not available** in Chrome 153 stable, so
  installs cannot be scripted; do step 5 by hand.
- **Background running**: closing a web app window does not quit it (normal
  macOS behaviour); use Cmd+Q. Chrome can also stay alive for notifications
  unless Settings > System > Continue running background apps when Google
  Chrome is closed is off.
- AeroSpace: Gmail goes to workspace `M` by bundle id. The generic
  `app-name-regex-substring = 'Chrome'` rule does not match PWAs, since their
  app name is the site name. Unassigned apps (Muse) fall to the catch-all.

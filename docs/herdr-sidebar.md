# Herdr sidebar: logos, colours, and fonts

The Herdr sidebar shows a coloured logo next to each agent and next to the
`bte`, `stryde`, and `vqa` spaces. Four pieces make that work. All of them are
tracked under `mac/.config/herdr/`.

| Piece | Path | Job |
|---|---|---|
| Row layout and colours | `config.toml`, the `[ui.sidebar.*]` tables | Decides what each sidebar row shows and in which colour |
| Agent logos | `agent-icons/` | Plugin that reports a `harness_logo` token for each agent pane |
| Space logos | `workspace-keepers/config.json` | Maps each space label to its `bte_logo` token |
| Glyphs | `fonts/` | Builds the terminal fonts that contain the logo glyphs |

The logos are ordinary text. Each one is a private-use codepoint that only the
JetBrains Mono Herdr fonts can draw, so a missing font shows up as an empty box
or a blank gap in the sidebar.

## How a logo reaches the screen

1. A plugin reports a text token on a pane or a workspace. The token is the
   glyph followed by a name, for example ` claude`.
2. `config.toml` places that token in a sidebar row and colours it.
3. Alacritty draws the glyph using `JetBrains Mono Herdr XL`, set in
   `mac/.config/alacritty/alacritty.toml`.

## Glyph map

| Codepoint | Logo | Used by | Notes |
|---|---|---|---|
| `U+E1A0` | claude | agent | |
| `U+E1A1` | codex | agent | |
| `U+E1A2` | opencode | agent | |
| `U+E1A3` | omp | agent | |
| `U+E1A4` | cline | agent | |
| `U+E1A5` | mastracode | agent | |
| `U+E1A6` | kimi | agent | |
| `U+E1A7` | kilo | agent | |
| `U+E1A8` | maki | agent | |
| `U+E1A9` | pi | agent | XL font only |
| `U+E1AA` | fx | agent | XL font only |
| `U+E1AB` | amp | agent | XL font only. A wordmark that overflows its cell, so the token is the glyph plus two spaces with no name |
| `U+E1AC` | bte | space | XL font only. Double width, so `config.json` puts two spaces after it |
| `U+E1AD` | stryde | space | XL font only |
| `U+E1AE` | vqa | space | XL font only |

`U+E1AF` is the next free codepoint.

## Colours

Set in `config.toml`. Agents get one row definition each under
`[ui.sidebar.agents.rows_by_agent]`. Spaces share a single row whose colour is
picked by a `contains` rule on the label.

| Item | Colour |
|---|---|
| claude | `#E68A67` |
| codex | `#A78BFA` |
| amp | `#DFDFC1` |
| pi | `#FFFFFF` |
| opencode and any other agent | `#A8ADB9` |
| a token containing ` fx` | `#D6D6D6` |
| bte | `#00D2BE` |
| vqa | `#00B8F2` |
| stryde | `#3B82F6` |
| spaces without a rule (`general`, `personal`) | `#A8ADB9` |

After editing, apply with `herdr server reload-config`. It reports config
diagnostics and does not restart panes.

## Agent logos plugin

`mac/.config/herdr/agent-icons/` is a trimmed local copy of
[moneycaringcoder/herdr-agent-icons](https://github.com/moneycaringcoder/herdr-agent-icons)
at commit `5a87c6ab`, linked into Herdr as a local plugin. It keeps the
upstream plugin id `moneycaringcoder.agent-icons`, so its settings stay in
`~/.config/herdr/plugins/config/moneycaringcoder.agent-icons/config.toml`
(`variant = "font"`).

It was moved here from Herdr's GitHub-managed plugin folder because that folder
is replaced on plugin updates, which would have dropped the local edits. Those
edits are recorded in `agent-icons/local-changes.patch`:

- adds the amp, pi, and fx logos
- reports `<glyph> <agent>` instead of the bare glyph
- tolerates panes with no `agent` field at startup

The script runs once at server start and once per `pane.agent_detected` event,
for roughly 150 ms each time. Nothing stays running.

```sh
# Relink on a new machine
herdr plugin link ~/.dotfiles/mac/.config/herdr/agent-icons --enabled

# Reapply logos to all current panes
herdr plugin action invoke refresh --plugin moneycaringcoder.agent-icons

# Recent runs and exit codes
herdr plugin log list --plugin moneycaringcoder.agent-icons --limit 10
```

To pick up upstream changes, diff upstream against this copy by hand and keep
the three edits above. Do not `herdr plugin install` it from GitHub again while
the local link exists.

## Host logos

Row 2 of every agent row starts with `$host_logo`, which shows the machine
the agent runs on. The same `agent-icons` plugin sets it on each pane. Plugins
run on the server that owns the pane, so each machine reports its own glyph.
These are stock Nerd Font glyphs, already in both Herdr fonts.

| Machine | Glyph | Codepoint | Colour |
|---|---|---|---|
| macOS (this Mac) | Apple | `U+F179` | `#6B7089` (dim, the default) |
| Arch-based Linux (omarchy) | Arch | `U+F303` | `#1793D1` (via a `contains` rule) |
| Ubuntu | Ubuntu | `U+F31B` | `#6B7089` |
| other Linux | Tux | `U+F17C` | `#6B7089` |
| Windows | Windows | `U+F17A` | `#6B7089` |

omarchy (`vp@omarchy`) is a saved Herdr machine (`herdr machine list`). It
keeps its own live `~/.config/herdr/config.toml` with Linux keybindings, not a
symlink to this repo, so sidebar row changes must be applied there separately.
Its plugin is linked from its own `~/.dotfiles` checkout.

## State emoji

Each agent row is one line: state emoji, host logo, agent logo, space, tab.
The agent-icons plugin reports `$state_emoji` alongside `$host_logo` and
`$harness_logo` (logo only, no agent name), replacing Herdr's dot, since done
and idle were both green. It reruns on `pane.agent_status_changed` and
`pane.focused` (which turns done into idle).

| State | Emoji |
|---|---|
| blocked | 🚨 |
| done | ✅ |
| working | 🟡 |
| idle | 💤 |

After editing `config.toml`, run `herdr server reload-config`.

## Space logos

`mac/.config/herdr/workspace-keepers/config.json` maps a space label to the
text shown for it. `keepers.py` writes that text to the workspace as the
`bte_logo` token on startup and on workspace events. The token is named
`bte_logo` for historical reasons and carries the text for every space,
including spaces with no logo, where it is just the label.

Resurrection of closed spaces is a separate job of the same plugin. See
`docs/herdr-workspace-keepers.md`.

## Fonts

Two installed families carry the glyphs. Both are stock JetBrainsMono Nerd
Font Mono 3.5.1 with extra glyphs grafted on.

| Family | Glyphs | Used by |
|---|---|---|
| `JetBrains Mono Herdr XL` | all 15, drawn large | Alacritty |
| `JetBrains Mono Herdr` | first 9, drawn at cell size | Herdr GPUI (`~/.config/herdr/config-gpui.local.toml`) |

The 2.5 MB font files are not tracked. `mac/.config/herdr/fonts/` holds what is
needed to rebuild them:

- `logos-xl.ttf` and `logos.ttf`: small donor fonts containing only the logo
  glyphs for each family
- `build-fonts`: grafts a donor onto the four base styles (Regular, Italic,
  Light, LightItalic) and renames the result
- `svg/`: source artwork for the amp, fx, and pi glyphs

```sh
cd ~/.dotfiles/mac/.config/herdr/fonts

./build-fonts --check     # do the installed fonts match a fresh build?
./build-fonts --install   # write all eight files to ~/Library/Fonts
./build-fonts             # write to ./build without installing
```

The base fonts must be installed first
(`brew install --cask font-jetbrains-mono-nerd-font`). Restart Alacritty after
installing so it loads the new files.

`--check` compares names, the character map, glyph order, every advance
width, and the logo outlines. It passed against the installed fonts on
2026-10-07.

Other Herdr fonts in `~/Library/Fonts` are not produced by this script and are
not referenced by any tracked config: `JetBrains Mono Herdr Large` (an unused
middle size) and `Herdr Harness Logos` (the upstream plugin's standalone font).

## Adding a logo

1. Add the glyph to `fonts/logos-xl.ttf` at the next free codepoint. The font
   uses 1000 units per em and a 600 unit cell. Use an advance width of 600, or
   1200 for a double-width logo. This step is manual (a font editor, or
   fontTools) and has no script. The source SVGs for bte, stryde, and vqa were
   not kept, so the donor font is their only source.
2. Run `./build-fonts --install` and restart Alacritty.
3. Wire up the token:
   - agent: add the codepoint to `PUA_LOGOS` and a fallback to `TEXT_LOGOS` in
     `agent-icons/agent_icons.py`, then add a row under
     `[ui.sidebar.agents.rows_by_agent]` in `config.toml`
   - space: add the label to `workspace-keepers/config.json`, then add a
     `contains` colour rule under `[ui.sidebar.spaces]`
4. Run `herdr server reload-config`, then the plugin's refresh or reconcile
   action.
5. Update the glyph map and colour table above.

## Known limits

- The collapsed sidebar rail (`Ctrl+B`, then `b`) shows only an index number
  and a status icon. That layout is hardcoded in Herdr's
  `render_collapsed_sidebar`, as of v0.9.3, so the logos cannot appear there
  without patching Herdr.
- `JetBrains Mono Herdr` lacks the six newest glyphs, so it cannot draw the
  space logos or the pi, fx, and amp logos.
- `~/.config/herdr/config-gpui.local.toml` is written by the Herdr GPUI app and
  is not tracked. It currently sets `layout = "comfortable-rounded"`,
  `theme = "Adventure"`, and the terminal family `JetBrains Mono Herdr`.
- `qintmb.herdr-icon-agent-ui` is an earlier logo plugin that is still
  installed but disabled. `mac/.config/herdr/herdr-sidebar-setup/install.json`
  is its installer's undo record.

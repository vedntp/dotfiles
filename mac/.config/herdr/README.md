# Herdr

## What lives here

| Path | What it is | Docs |
|---|---|---|
| `config.toml` | Keybindings, UI, sidebar rows and colours | `docs/shortcut-reference.md`, `docs/herdr-sidebar.md` |
| `load-status` | CPU, GPU and memory for the TUI tab bar (`ui.tab_bar_right`), macOS and Linux. GPU comes from `ioreg` on macOS and `nvidia-smi` (or amdgpu's `gpu_busy_percent`) on Linux. omarchy runs its own copy from its `~/.dotfiles` | `config.toml` |
| `agent-icons/` | Local plugin that reports agent logos to the sidebar | `docs/herdr-sidebar.md` |
| `workspace-keepers/` | Local plugin that restores protected spaces and sets their logos | `docs/herdr-workspace-keepers.md` |
| `fonts/` | Donor glyphs and build script for the logo fonts | `docs/herdr-sidebar.md` |
| `plugins/herdr-focus-notify/` | Separate clone, ignored by Git | end of this file |
| `initial-host-theme-replay.patch` | Local binary patch, ignored by Git | below |
| `herdr-sidebar-setup/` | Undo record from a disabled earlier logo plugin | `docs/herdr-sidebar.md` |

Stow links only `config.toml` into `~/.config/herdr/`. The two local plugins
are registered by path with `herdr plugin link`, so they keep working from
this directory.

# Herdr maintenance handoff

Last checked: 2026-10-07. Read this before updating or troubleshooting this user's Herdr installation. This note is a historical record, not a live release check.

## Current state (2026-10-20)

- Installed: **0.9.5** from tag `v0.9.5` (commit `2ecf19a`) plus seven patches saved here, applied in the order listed, SHA-256 `7a4ec0fcd4d771ba...`:
  - `initial-host-theme-replay.patch`: the theme patch below, rebased onto 0.9.5 (the 0.9.3 file no longer applied). Client side.
  - `remote-switch-seen.patch`: the server treated "client viewing another machine" as unknown focus, which counted as seen, so agents finishing there went idle instead of done. Server side, so it only takes effect after a server restart. omarchy (0.9.1) needs the same patch for the reverse direction.
  - `sidebar-row-indent.patch`: agent sidebar rows after the first start in the same column as the first. Client side.
  - `seen-status-event.patch`: emits `pane.agent_status_changed` when only `seen` flips (done to idle on viewing), which Herdr never did. Server side.
  - `next-machine.patch` (2026-10-22): new `keys.next_machine` action that jumps to the first space (sidebar order) of the next online machine, bound to `prefix+m` and sent by Alacritty's Ctrl+`. Client side; an unpatched server logs `unknown config key keys.next_machine` on reload, which is harmless. Installed SHA-256 `33090352bb8f574f...`.
  - `sidebar-custom-token-spacing.patch` (2026-10-23): plugin `$tokens` sit one space from their neighbours in sidebar rows instead of ` · `; rows of built-in tokens keep the dots, so upstream tests pass unchanged. Client side.
  - `sidebar-priority-gaps.patch` (2026-10-23): with `agent_panel_sort = "priority"`, a blank line between agents that need you (blocked, done), working and idle ones. Client side. Layout in `docs/herdr-sidebar.md`.
- Build: Homebrew's Zig is too new; unpack Zig 0.16.0 from ziglang.org and pass it as `ZIG=.../zig cargo build --release --bin herdr`. Install by copying next to `~/.local/bin/herdr` and `mv` over it, so the running server keeps its file; then reattach the client. In this sandbox the full `cargo test` run fails 13 plugin-path and manifest tests that pass when run alone, with or without these patches.
- Rollback: `mv ~/.local/bin/herdr.0.9.5-pre-sidebar ~/.local/bin/herdr` (drops only the two sidebar patches), or `mv ~/.local/bin/herdr.0.9.5-pre-next-machine ~/.local/bin/herdr` (drops next-machine too), or `mv ~/.local/bin/herdr.0.9.5-pre-seen-fix ~/.local/bin/herdr`, then reattach.
- omarchy (2026-10-20): same patched 0.9.5 built in `~/.cache/herdr-build` (rustup and zig in user space) and installed over the pacman file `/usr/bin/herdr`, so a pacman update of `herdr` will replace it. Swapped in with `herdr server live-handoff --import-exe /usr/bin/herdr --expected-protocol 22`; panes and agents survived. Rollback: `sudo install -m755 ~/.local/bin/herdr.0.9.1-pacman /usr/bin/herdr`, then hand off again. Its state loop runs as the systemd user service `herdr-pulse`.
- omarchy (2026-10-23): rebuilt with all seven patches in `~/.cache/herdr-build/src` (Zig 0.16.0 unpacked beside it, Rust from `~/.cargo/bin`), installed over `/usr/bin/herdr` with `sudo` (pkexec has no prompt over SSH), SHA-256 `7adea7f182a373a0...`. Only client code changed, so the running server needed no handoff. Rollback: `sudo install -m755 ~/.local/bin/herdr.0.9.5-pre-sidebar /usr/bin/herdr`. Its plugin files were copied from this Mac (its checkout is behind origin), and its own `config.toml` carries the same sidebar section.

## Earlier state (2026-10-07, historical)

- Installed executable: `/Users/vp/.local/bin/herdr`.
- Version: **0.9.3 with the local 8-line host-theme replay patch**. `herdr --version` prints `herdr 0.9.3`; the version string does not identify the patch.
- Patched 0.9.3 binary SHA-256: `58de075e0391a9517adb10d975e2bf5325915054d8a6f6a4bd48c530dd37f006`.
- Built from official tag `v0.9.3`, commit `7b116c05bfda646af39d2524c54e70c751f57ee8`. The saved patch applied with `git apply` unchanged.
- Previous working build, patched 0.9.1: `/Users/vp/.local/bin/herdr.0.9.1-theme-replay`, SHA-256 `8097f9969e7a6f392abf7678984dff5003ac58b88779d9b39290121d93a32a9e`. This is the rollback target.
- Original UNPATCHED 0.9.1: `/Users/vp/.local/bin/herdr.pre-theme-replay-0.9.1`, SHA-256 `5fc7a7e7adfaca56fa80aa89dcb025693357268dab8285b9ce2d08a2313c89de`.
- Exact patch is saved alongside this note as `initial-host-theme-replay.patch`.
- On October 7, the latest official stable release was v0.9.3. Its `install_client_shell_snapshot` still did not replay the host theme, so the patch is still needed. Recheck online before giving future update advice.
- The binary was swapped while the 0.9.1 server kept running (both speak private protocol 22), then the user reattached and later restarted the server. `herdr status` now reports client and server 0.9.3 with `server_binary_stale: no`.
- Checked on 0.9.3: the user confirmed the reattach and the gray Codex composer background; after the server restart all five spaces came back with their logo tokens, the three local plugins loaded, and plugin runs exited 0.
- Rollback: `cp -p ~/.local/bin/herdr.0.9.1-theme-replay ~/.local/bin/herdr`, then reattach.
- Homebrew did not manage Herdr when checked. Ordinary `brew upgrade` did not affect this installation. Recheck ownership/path if the user's installation changes.

## User's problem and diagnosis

Codex CLI displayed a gray background behind its composer and user messages in direct Alacritty, but often displayed plain, unshaded areas inside Herdr. The user strongly prefers the gray backgrounds because they distinguish user prompts from assistant output. Both appearances had also occurred simultaneously inside Herdr.

Multiple Codex installations were initially present and later consolidated, but the rendering problem persisted with the same standalone Codex 0.155.0 executable. Focus, pane width, and restarting Herdr did not resolve it. Do not restart the investigation by assuming duplicate binaries caused this.

Relevant Codex source comparison between tags `rust-v0.151.0` and `rust-v0.155.0` found the same composer background logic. `user_message_style_for` uses a background only when terminal background discovery succeeds. Without a detected background, it returns the default unshaded style. The relevant terminal palette/probe files were identical between those tags.

Herdr v0.9.1 can receive Alacritty's OSC 10/11 foreground/background replies before its active endpoint is online. The client records these host-theme updates locally, but skips sending them while the endpoint is offline. The initial snapshot installation did not replay those retained updates. Thus pane applications can lack the host colors needed for Codex's shading.

Source inspection established this missing replay path. An earlier pane probe received a cursor-position reply but no OSC 10/11 replies. We did not capture the exact dropped startup reply in the live user's process. After installing the patch and reconnecting the client, the user reported: "ok done. seems to be working". This supports the diagnosis; no repeated-start automated verification was completed.

## Patch and provenance

Official base tag: `v0.9.1`, commit `065ef9d6a531c49fb8bee7e818ef837065b21ee9`.

Changed file: `src/client/shell_runtime.rs`, function `install_client_shell_snapshot`.

Before installing the first active endpoint snapshot, record whether that endpoint lacks a snapshot. After installing/presenting it, call the existing `state.replay_host_theme(endpoints, endpoint_id)` when that condition was true. This forwards retained terminal colors through the existing protocol. No Codex source or configuration changes were needed for this fix.

Sources:

- Official repository: https://github.com/herdrdev/herdr
- Matching report: https://github.com/herdrdev/herdr/issues/3892
- Downstream patch: https://github.com/hdosys/herdr-ext/commit/286349a76754d2c1cf6b46ad66d9dabb4e501ac1
- Official release: https://github.com/herdrdev/herdr/releases/tag/v0.9.1
- Codex styling: https://github.com/openai/codex/blob/rust-v0.155.0/codex-rs/tui/src/style.rs

The downstream patch was backported to official Herdr source. The full fork was not installed.

## Instructions for a future Codex conversation

1. Read this note and the adjacent patch. Respect the user's current request: an update check is not permission to install, rebuild, restart, or modify configuration.
2. Check the installed binary's version, resolved path, and SHA-256. A different checksum means inspect further; it does not by itself prove the fix is missing.
3. Check the latest official stable release using GitHub's releases API/page. Inspect the released source for equivalent initial host-theme replay, including refactored implementations. A fix on the development branch is not necessarily released.
4. If no newer stable release exists, recommend keeping the working patched build.
5. If a newer release includes an equivalent fix, explain that the custom patch can be retired and offer the normal update. Obtain approval before installing unless the current request already authorizes it.
6. If a newer release lacks the fix, explain the tradeoff. With approval, build and test an isolated patched copy before replacement. Do not blindly apply the old patch to changed code or install an entire unrelated fork.
7. Validate both host-color replies and a fresh Codex composer's gray background. Repeated new launches are useful because this was a startup timing problem. A visible gray background once does not prove upstream contains the fix; inspect source too.
8. Preserve the known-working patched executable before any future replacement. The existing `pre-theme-replay` backup is the original UNPATCHED binary, not a backup of the working patch.
9. Update this note after an approved change with the actual version, source revision, checksum, test outcome, and rollback location.

## Build record

The 0.9.1 and 0.9.3 builds both used macOS arm64, the repository-pinned Rust 1.96.1 toolchain, and Zig 0.16.0 (Homebrew Zig 0.17.0 is too new; a 0.16.0 tarball from ziglang.org was unpacked to a temporary directory and passed through `ZIG`). The 0.9.3 release build took about two and a half minutes. The paths below are from the 0.9.1 build.

Successful build used macOS arm64, the repository-pinned Rust 1.96.1 toolchain, and Zig 0.16.0. Cargo downloaded Rust 1.96.1 through rustup; Zig was unpacked into a temporary directory. The global default Rust toolchain was not intentionally changed.

Historical command:

```sh
CARGO_TARGET_DIR=/tmp/herdr-target.o9CNEW \
ZIG=/tmp/zig-herdr.Vv4gFM/zig-aarch64-macos-0.16.0/zig \
cargo build --release --locked
```

Historical source: `/tmp/herdr-patched.o9CNEW/source`.
Historical output: `/tmp/herdr-target.o9CNEW/release/herdr`.
These temporary paths may disappear. Fetch a fresh official source checkout and the appropriate toolchain if needed. Apply the saved patch with `git apply --check` before `git apply`.

Completed checks were successful release compilation, `git diff --check`, architecture/version checks, checksum verification, and the user's visual confirmation after reconnecting. The binary was installed before the planned isolated behavioral test, so do not claim that test passed.

## Starting, stopping, and updating

- Closing/detaching the Herdr client leaves the server and pane processes running. Running `herdr` again loads the installed client and reattaches.
- This patch is in the client. Reconnecting the patched client was sufficient in this case; stopping the server was unnecessary.
- `herdr server stop` terminates pane processes, including running agents. Do not use it casually or kill the main Herdr process. Follow the Herdr skill and current user authorization.
- After an intentional server stop, running `herdr` starts a server again. Saved layout/session restoration does not mean the original processes survived.
- Closing/reopening Herdr, stopping/starting it, and rebooting the Mac do not remove the patch from the installed executable.
- `herdr update` or an installer can replace the executable and remove the local patch if the installed release lacks the fix.
- Recheck Homebrew ownership before repeating advice about `brew upgrade`; Herdr was not a Homebrew package at the time of this repair.

## Related Codex cleanup

Earlier in this conversation the Bun Codex copy and the global npm Codex copy under `/opt/homebrew` were removed. The latter was not actually a Homebrew Codex cask. Standalone Codex remained at `/Users/vp/.local/bin/codex`.

Aliases established then in `.zshrc`:

```zsh
alias cx="$HOME/.local/bin/codex --yolo"
alias cx-update='curl -fsSL https://chatgpt.com/codex/install.sh | sh'
```

These are historical details, not permission to change aliases, reinstall Codex, or alter permissions. Inspect their current state only if relevant.

## User preferences

- Explain the plan and wait when asked to discuss before implementation. Earlier unauthorized changes caused frustration.
- Give conclusions grounded in source and observed behavior; clearly distinguish untested inferences.
- Do not read or write the Obsidian vault unless explicitly requested. This note is deliberately stored outside the vault.
- Do not use em dashes.

## herdr-focus-notify (not tracked here)

`plugins/herdr-focus-notify/` is a separate clone of
https://github.com/yankewei/herdr-focus-notify with local edits to
`src/*.rs` and `tests/cli_test.rs`. It has its own `.git`, so it is ignored by
this repository. `config.toml` sets `ui.toast.delivery = "herdr"` on the
assumption that this plugin owns desktop notifications. To reinstall on a new
machine, clone the upstream repo into `plugins/` and reapply the local edits
(push them to a fork to keep them).

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

## Current state

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

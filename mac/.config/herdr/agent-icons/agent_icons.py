#!/usr/bin/env python3
"""Apply display-only icons to Herdr agent names."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import unicodedata
from pathlib import Path
from typing import Any

try:
    import tomllib
except ModuleNotFoundError:
    # A Herdr server started at login gets macOS's Python 3.9, which has no
    # tomllib. The config is one `variant = "..."` line, so read it directly.
    tomllib = None

FONT_FAMILY = "Herdr Harness Logos"
TOKEN_NAME = "harness_logo"
PUA_LOGOS = {
    "amp": "\ue1ab",
    "claude": "\ue1a0",
    "codex": "\ue1a1",
    "opencode": "\ue1a2",
    "omp": "\ue1a3",
    "cline": "\ue1a4",
    "mastracode": "\ue1a5",
    "kimi": "\ue1a6",
    "kilo": "\ue1a7",
    "maki": "\ue1a8",
    "pi": "\ue1a9",
    "fx": "\ue1aa",
}
TEXT_LOGOS = {
    "amp": "AMP",
    "claude": "C",
    "codex": "AI",
    "opencode": "OC",
    "omp": "OMP",
    "cline": "CL",
    "mastracode": "MC",
    "kimi": "KIM",
    "kilo": "KIL",
    "maki": "MAK",
    "pi": "π",
    "fx": "\ue1aa",
}
VARIANTS = ("auto", "font", "text", "none")
# Agent state, the first item on each row. Loud for what needs you.
STATE_TOKEN_NAME = "state_emoji"
CLUSTER_TOKEN_NAME = "agent_cluster"
STATE_EMOJIS = {
    "blocked": "🚨",
    "done": "✅",
    "working": "🟡",
    "idle": "\u26aa\ufe0f",  # full-size emoji style, same size as 🟡
}
# Enlarged copies of the Nerd Font host glyphs, added by fonts/build-fonts.
HOST_TOKEN_NAME = "host_logo"
HOST_LOGOS = {
    "macos": "\ue1b0",  # nf-fa-apple
    "arch": "\ue1b1",  # nf-linux-archlinux
    "ubuntu": "\ue1b2",  # nf-linux-ubuntu
    "linux": "\ue1b3",  # nf-fa-linux
    "windows": "\ue1b4",  # nf-fa-windows
}


def run_herdr(herdr: str, *args: str) -> dict[str, Any]:
    # Herdr runs plugin commands with a minimal PATH, so `herdr` is not
    # necessarily resolvable from it. HERDR_BIN_PATH is the supported way in,
    # and its absence has to read as a plain message rather than a traceback.
    try:
        result = subprocess.run(
            [herdr, *args],
            check=False,
            capture_output=True,
            text=True,
        )
    except OSError as error:
        raise RuntimeError(f"could not run {herdr!r}: {error}") from error
    if result.returncode != 0:
        message = result.stderr.strip() or result.stdout.strip()
        raise RuntimeError(message or f"Herdr exited with status {result.returncode}")
    if not result.stdout.strip():
        return {}
    return json.loads(result.stdout)


def cell_width(text: str) -> int:
    width = 0
    for character in text:
        if unicodedata.category(character).startswith("C") and not (0xE000 <= ord(character) <= 0xF8FF):
            raise ValueError(f"non-printing character U+{ord(character):04X}")
        if unicodedata.combining(character):
            continue
        width += 2 if unicodedata.east_asian_width(character) in {"W", "F"} else 1
    return width


def font_available() -> bool:
    fc_match = shutil.which("fc-match")
    if fc_match is None:
        return False
    result = subprocess.run(
        [fc_match, "--format", "%{family}\n", FONT_FAMILY],
        check=False,
        capture_output=True,
        text=True,
    )
    families = {name.strip() for line in result.stdout.splitlines() for name in line.split(",")}
    return result.returncode == 0 and FONT_FAMILY in families


def configured_variant(explicit: str | None = None) -> str:
    if explicit is not None:
        return explicit
    config_dir = os.environ.get("HERDR_PLUGIN_CONFIG_DIR")
    if not config_dir:
        return "auto"
    config_path = Path(config_dir) / "config.toml"
    if not config_path.is_file():
        return "auto"
    if tomllib is not None:
        with config_path.open("rb") as config_file:
            variant = tomllib.load(config_file).get("variant", "auto")
    else:
        variant = "auto"
        for line in config_path.read_text().splitlines():
            key, _, value = line.partition("=")
            if key.strip() == "variant":
                variant = value.split("#")[0].strip().strip('"')
    if variant not in VARIANTS:
        raise RuntimeError(f"invalid variant {variant!r} in {config_path}")
    return variant


def logo_for(agent: str, variant: str) -> str | None:
    if agent not in PUA_LOGOS or variant == "none":
        return None
    if variant == "auto":
        variant = "font" if font_available() else "text"
    return PUA_LOGOS[agent] if variant == "font" else TEXT_LOGOS[agent]


def host_logo() -> str:
    # Plugins run on the server that owns the pane, so this is the machine the
    # agent itself runs on, even when the sidebar shows it from another one.
    if sys.platform == "darwin":
        return HOST_LOGOS["macos"]
    if sys.platform == "win32":
        return HOST_LOGOS["windows"]
    distros: set[str] = set()
    try:
        for line in Path("/etc/os-release").read_text().splitlines():
            key, _, value = line.partition("=")
            if key in {"ID", "ID_LIKE"}:
                distros.update(value.strip('"').split())
    except OSError:
        pass
    for distro in ("arch", "ubuntu"):
        if distro in distros:
            return HOST_LOGOS[distro]
    return HOST_LOGOS["linux"]


def report_logo(
    herdr: str, source: str, pane_id: str, agent: str | None, variant: str, status: str | None = None
) -> bool:
    logo = logo_for(agent, variant) if agent is not None else None
    arguments = [
        "pane",
        "report-metadata",
        pane_id,
        "--source",
        source,
    ]
    if logo is None:
        arguments.extend(("--clear-token", TOKEN_NAME))
    else:
        # The logo alone identifies the agent; the name made rows too busy.
        arguments.extend(("--token", f"{TOKEN_NAME}={logo}"))
    if variant == "none":
        arguments.extend(("--clear-token", HOST_TOKEN_NAME))
    else:
        arguments.extend(("--token", f"{HOST_TOKEN_NAME}={host_logo()}"))
    emoji = STATE_EMOJIS.get(status or "") if logo is not None else None
    if emoji is None:
        arguments.extend(("--clear-token", STATE_TOKEN_NAME, "--clear-token", CLUSTER_TOKEN_NAME))
    else:
        arguments.extend(("--token", f"{STATE_TOKEN_NAME}={emoji}"))
        # State, host and agent in one token, so Herdr draws no " · " between them.
        arguments.extend(("--token", f"{CLUSTER_TOKEN_NAME}={emoji} {host_logo()} {logo}"))
    run_herdr(herdr, *arguments)
    return logo is not None


def event_value(value: Any, key: str) -> str | None:
    if isinstance(value, dict):
        candidate = value.get(key)
        if isinstance(candidate, str):
            return candidate
        for child in value.values():
            found = event_value(child, key)
            if found is not None:
                return found
    elif isinstance(value, list):
        for child in value:
            found = event_value(child, key)
            if found is not None:
                return found
    return None


def event_pane(raw_event: str) -> str | None:
    try:
        event = json.loads(raw_event)
    except json.JSONDecodeError as error:
        raise RuntimeError(f"invalid HERDR_PLUGIN_EVENT_JSON: {error}") from error
    pane_id = event_value(event, "pane_id")
    return pane_id


def current_target(herdr: str, pane_id: str) -> tuple[str, str | None, str | None]:
    response = run_herdr(herdr, "pane", "get", pane_id)
    pane = response.get("result", {}).get("pane", {})
    agent = pane.get("agent")
    return pane_id, agent if isinstance(agent, str) else None, pane.get("agent_status")


def startup_targets(herdr: str) -> list[tuple[str, str | None, str | None]]:
    response = run_herdr(herdr, "pane", "list")
    panes = response.get("result", {}).get("panes", [])
    return [
        (pane["pane_id"], pane.get("agent"), pane.get("agent_status"))
        for pane in panes
        if isinstance(pane, dict)
        and isinstance(pane.get("pane_id"), str)
        and (pane.get("agent") is None or isinstance(pane.get("agent"), str))
    ]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pane")
    parser.add_argument("--agent")
    parser.add_argument("--source")
    parser.add_argument("--variant", choices=VARIANTS)
    args = parser.parse_args()

    herdr = os.environ.get("HERDR_BIN_PATH", "herdr")
    plugin_id = os.environ.get("HERDR_PLUGIN_ID", "moneycaringcoder.agent-icons")
    source = args.source or f"plugin:{plugin_id}"
    variant = configured_variant(args.variant)

    if bool(args.pane) != bool(args.agent):
        parser.error("--pane and --agent must be supplied together")

    try:
        if args.pane and args.agent:
            targets = [(args.pane, args.agent, None)]
        elif os.environ.get("HERDR_PLUGIN_EVENT_JSON"):
            pane_id = event_pane(os.environ["HERDR_PLUGIN_EVENT_JSON"])
            targets = [] if pane_id is None else [current_target(herdr, pane_id)]
        else:
            targets = startup_targets(herdr)
    except (RuntimeError, json.JSONDecodeError) as error:
        print(error, file=sys.stderr)
        return 1

    failures = []
    for pane_id, agent, status in targets:
        try:
            report_logo(herdr, source, pane_id, agent, variant, status)
        except (RuntimeError, json.JSONDecodeError) as error:
            failures.append(f"{pane_id}: {error}")

    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

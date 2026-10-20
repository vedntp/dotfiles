#!/usr/bin/env python3
"""Keep each agent's $state_emoji current, pulsing it while the agent works.

Herdr sends no event when done turns into idle, so the plugin alone leaves a
stale done mark. This loop rereads every pane each tick, sets the emoji for
its state, and alternates the working emoji so it looks lit. It writes only
when a value changes. Run by a LaunchAgent (com.vp.herdr-pulse).
"""

from __future__ import annotations

import json
import os
import subprocess
import time

from agent_icons import STATE_EMOJIS, STATE_TOKEN_NAME

HERDR = os.environ.get("HERDR_BIN_PATH", os.path.expanduser("~/.local/bin/herdr"))
SOURCE = "plugin:moneycaringcoder.agent-icons"
# Font dots (fonts/build-fonts) coloured yellow and pale yellow by config.toml
# rules. Herdr trims trailing spaces, so a blank braille cell (U+2800) makes
# them two cells wide like the emoji.
WORKING_FRAMES = ("\ue1b8\u2800", "\ue1b9\u2800")
TICK_SECONDS = 0.6


def herdr(*args: str) -> dict:
    result = subprocess.run([HERDR, *args], check=False, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip())
    return json.loads(result.stdout or "{}")


def main() -> None:
    frame = 0
    while True:
        frame ^= 1
        try:
            panes = herdr("pane", "list")["result"]["panes"]
        except (RuntimeError, json.JSONDecodeError, KeyError):
            time.sleep(2)  # server restarting or not up yet
            continue
        for pane in panes:
            status = pane.get("agent_status")
            emoji = None
            if pane.get("agent"):
                emoji = WORKING_FRAMES[frame] if status == "working" else STATE_EMOJIS.get(status)
            pane_id = pane["pane_id"]
            current = pane.get("tokens", {}).get(STATE_TOKEN_NAME)
            if emoji == current:
                continue
            arguments = ["pane", "report-metadata", pane_id, "--source", SOURCE]
            if emoji is None:
                arguments += ["--clear-token", STATE_TOKEN_NAME]
            else:
                arguments += ["--token", f"{STATE_TOKEN_NAME}={emoji}"]
            try:
                herdr(*arguments)
            except (RuntimeError, json.JSONDecodeError):
                pass
        time.sleep(TICK_SECONDS)


if __name__ == "__main__":
    main()

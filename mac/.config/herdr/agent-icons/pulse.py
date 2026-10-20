#!/usr/bin/env python3
"""Keep each agent's $state_emoji current, pulsing it while the agent works.

Herdr sends no event when done turns into idle, so the plugin alone leaves a
stale done mark. This loop rereads every pane each tick, sets the emoji for
its state, and fades the working dot from yellow to white and back. It talks
to Herdr's API socket directly, since launching the CLI for every
frame cost about 10 ms of CPU. Run by a LaunchAgent (com.vp.herdr-pulse).
"""

from __future__ import annotations

import json
import os
import socket
import time

from agent_icons import STATE_EMOJIS, STATE_TOKEN_NAME

SOCKET = os.path.expanduser("~/.config/herdr/herdr.sock")
SOURCE = "plugin:moneycaringcoder.agent-icons"
# Font dots U+E1B8..U+E1BF (fonts/build-fonts), coloured yellow to white by
# config.toml rules. A blank braille cell (U+2800) makes each two cells wide
# like the emoji, since Herdr trims trailing spaces.
SHADES = [chr(code) + "⠀" for code in range(0xE1B8, 0xE1C0)]
WORKING_FRAMES = SHADES + SHADES[-2:0:-1]  # yellow to white and back
TICK_SECONDS = 0.1


class Herdr:
    """Herdr's API socket answers one request per connection."""

    def __init__(self) -> None:
        self.next_id = 0

    def call(self, method: str, params: dict) -> dict:
        self.next_id += 1
        request = {"id": f"pulse:{self.next_id}", "method": method, "params": params}
        with socket.socket(socket.AF_UNIX) as sock:
            sock.connect(SOCKET)
            sock.sendall(json.dumps(request).encode() + b"\n")
            with sock.makefile("rb") as reader:
                line = reader.readline()
        if not line:
            raise ConnectionError("herdr closed the socket")
        response = json.loads(line)
        if "error" in response:
            raise RuntimeError(response["error"])
        return response["result"]


def main() -> None:
    herdr = None
    frame = 0
    while True:
        try:
            if herdr is None:
                herdr = Herdr()
            frame = (frame + 1) % len(WORKING_FRAMES)
            for pane in herdr.call("pane.list", {})["panes"]:
                status = pane.get("agent_status")
                emoji = None
                if pane.get("agent"):
                    emoji = WORKING_FRAMES[frame] if status == "working" else STATE_EMOJIS.get(status)
                if emoji == pane.get("tokens", {}).get(STATE_TOKEN_NAME):
                    continue
                herdr.call(
                    "pane.report_metadata",
                    {"pane_id": pane["pane_id"], "source": SOURCE, "tokens": {STATE_TOKEN_NAME: emoji}},
                )
        except (OSError, ValueError, RuntimeError, KeyError):
            # Server restarting or not up yet: reconnect after a pause.
            herdr = None
            time.sleep(2)
            continue
        time.sleep(TICK_SECONDS)


if __name__ == "__main__":
    main()

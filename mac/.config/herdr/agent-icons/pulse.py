#!/usr/bin/env python3
"""Keep each agent's $state_bar and each space's $space_bar current.

Herdr sends no event when done turns into idle, so the plugin alone leaves a
stale done mark. This loop rereads every pane and space each tick and sets the
bar for its state. It talks to Herdr's API socket directly, since launching the
CLI every tick cost about 10 ms of CPU. Run by a LaunchAgent (com.vp.herdr-pulse).
"""

from __future__ import annotations

import json
import os
import socket
import time

from agent_icons import SPACE_STATE_TOKEN_NAME, STATE_BARS, STATE_TOKEN_NAME, space_bar

SOCKET = os.path.expanduser("~/.config/herdr/herdr.sock")
SOURCE = "plugin:moneycaringcoder.agent-icons"
TICK_SECONDS = 0.5


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
    while True:
        try:
            if herdr is None:
                herdr = Herdr()
            for pane in herdr.call("pane.list", {})["panes"]:
                bar = STATE_BARS.get(pane.get("agent_status")) if pane.get("agent") else None
                if bar == pane.get("tokens", {}).get(STATE_TOKEN_NAME):
                    continue
                herdr.call(
                    "pane.report_metadata",
                    {"pane_id": pane["pane_id"], "source": SOURCE, "tokens": {STATE_TOKEN_NAME: bar}},
                )
            for workspace in herdr.call("workspace.list", {})["workspaces"]:
                bar = space_bar(workspace)
                if bar == workspace.get("tokens", {}).get(SPACE_STATE_TOKEN_NAME):
                    continue
                herdr.call(
                    "workspace.report_metadata",
                    {"workspace_id": workspace["workspace_id"], "source": SOURCE, "tokens": {SPACE_STATE_TOKEN_NAME: bar}},
                )
        except (OSError, ValueError, RuntimeError, KeyError):
            # Server restarting or not up yet: reconnect after a pause.
            herdr = None
            time.sleep(2)
            continue
        time.sleep(TICK_SECONDS)


if __name__ == "__main__":
    main()

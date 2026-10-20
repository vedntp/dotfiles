#!/usr/bin/env python3
"""Report a $state_emoji token so sidebar rows show each agent's state at a glance."""

from __future__ import annotations

import json
import os
import subprocess
import sys

TOKEN_NAME = "state_emoji"
# Loud for what needs you, quiet for what doesn't.
EMOJIS = {
    "blocked": "🚨",
    "done": "✅",
    "working": "⏳",
    "idle": "💤",
}


def run_herdr(herdr: str, *args: str) -> dict:
    result = subprocess.run([herdr, *args], check=False, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or f"herdr {' '.join(args)} failed")
    return json.loads(result.stdout or "{}")


def event_pane(raw_event: str) -> str | None:
    def find(value):
        if isinstance(value, dict):
            if isinstance(value.get("pane_id"), str):
                return value["pane_id"]
            value = list(value.values())
        if isinstance(value, list):
            for child in value:
                found = find(child)
                if found:
                    return found
        return None

    return find(json.loads(raw_event))


def main() -> int:
    herdr = os.environ.get("HERDR_BIN_PATH", "herdr")
    source = f"plugin:{os.environ.get('HERDR_PLUGIN_ID', 'moneycaringcoder.agent-icons')}:state"
    raw_event = os.environ.get("HERDR_PLUGIN_EVENT_JSON")
    if raw_event:
        pane_id = event_pane(raw_event)
        panes = [] if pane_id is None else [run_herdr(herdr, "pane", "get", pane_id)["result"]["pane"]]
    else:
        panes = run_herdr(herdr, "pane", "list")["result"]["panes"]

    failures = []
    for pane in panes:
        emoji = EMOJIS.get(pane.get("agent_status", "")) if pane.get("agent") else None
        arguments = ["pane", "report-metadata", pane["pane_id"], "--source", source]
        if emoji is None:
            arguments += ["--clear-token", TOKEN_NAME]
        else:
            arguments += ["--token", f"{TOKEN_NAME}={emoji}"]
        try:
            run_herdr(herdr, *arguments)
        except (RuntimeError, json.JSONDecodeError) as error:
            failures.append(f"{pane['pane_id']}: {error}")
    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

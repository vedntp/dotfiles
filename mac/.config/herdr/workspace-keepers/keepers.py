#!/usr/bin/env python3
"""Event-driven resurrection of protected Herdr workspace containers."""
import fcntl
import json
import os
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parent
BIN = os.environ.get("HERDR_BIN_PATH", "herdr")

def cli(*args):
    p = subprocess.run([BIN, *args], capture_output=True, text=True, timeout=15)
    if p.returncode:
        raise RuntimeError(p.stderr.strip() or p.stdout.strip())
    return json.loads(p.stdout)["result"] if p.stdout.strip() else {}

def main():
    if os.environ.get("HERDR_ENV") != "1":
        raise RuntimeError("Run inside Herdr or as a Herdr plugin.")
    configured = json.loads((ROOT / "config.json").read_text())
    state_dir = Path(os.environ.get("HERDR_PLUGIN_STATE_DIR", str(Path.home() / ".local/state/herdr-workspace-keepers")))
    state_dir.mkdir(parents=True, exist_ok=True)
    with (state_dir / "lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        state_file = state_dir / "state.json"
        try:
            state = json.loads(state_file.read_text())
        except (FileNotFoundError, ValueError):
            state = {}
        snapshot = cli("api", "snapshot")["snapshot"]
        workspaces = snapshot["workspaces"]
        # Display metadata is not retained across server restarts. Restore it
        # for every existing workspace, independently of resurrection protection.
        for workspace in workspaces:
            label = workspace["label"]
            display = configured.get(label, label)
            if workspace.get("tokens", {}).get("bte_logo") != display:
                cli("workspace", "report-metadata", workspace["workspace_id"],
                    "--source", "local.workspace-keepers", "--token", f"bte_logo={display}")
        for label, logo_token in configured.items():
            matches = [w for w in workspaces if w["label"] == label]
            if len(matches) > 1:
                print("Ambiguous label, skipped:", label)
                continue
            record = state.setdefault(label, {})
            cwd = record.get("cwd", str(Path.home()))
            if matches:
                workspace = matches[0]
                # Keep the most recent existing pane directory as the recovery cwd.
                candidates = [p for p in snapshot["panes"] if p["workspace_id"] == workspace["workspace_id"]]
                if candidates and candidates[0].get("cwd"):
                    cwd = candidates[0]["cwd"]
                record["cwd"] = cwd
                continue
            # A short circuit breaker prevents an event storm from creating duplicates.
            if os.environ.get("HERDR_PLUGIN_EVENT") != "workspace.closed" and time.time() - record.get("created_at", 0) < 3:
                print("Rapid repeated closure, skipped:", label)
                continue
            result = cli("workspace", "create", "--label", label, "--cwd", cwd, "--no-focus")
            workspace = result["workspace"]
            cli("workspace", "report-metadata", workspace["workspace_id"],
                "--source", "local.workspace-keepers", "--token", f"bte_logo={logo_token}")
            record.update({"cwd": cwd, "created_at": time.time()})
            print("Recreated workspace:", label)
        tmp = state_file.with_suffix(".tmp")
        tmp.write_text(json.dumps({k: v for k, v in state.items() if k in configured}, indent=2))
        tmp.replace(state_file)

if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        sys.exit(1)

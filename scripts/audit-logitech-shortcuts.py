#!/usr/bin/env python3
"""Read-only drift audit for the documented MX Master 3S Options+ profile."""

from __future__ import annotations

import argparse
import json
import os
import sqlite3
import sys
from pathlib import Path
from typing import Any


DEFAULT_MANIFEST = Path(__file__).resolve().parents[1] / "docs" / "logitech-mx-master-3s-shortcuts.json"
DEFAULT_DATABASE = Path.home() / "Library/Application Support/LogiOptionsPlus/settings.db"


def canonical(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def relevant(value: Any) -> Any:
    """Drop Options+ UI metadata that varies by application/profile version."""
    volatile = {"applicationId", "taskId", "tags", "icons", "category"}
    if isinstance(value, dict):
        return {key: relevant(item) for key, item in value.items() if key not in volatile}
    if isinstance(value, list):
        return [relevant(item) for item in value]
    return value


def load_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def load_settings(path: Path) -> dict[str, Any]:
    # URI mode=ro is intentional.  No connection opened by this utility can write.
    uri = "file:" + os.fspath(path) + "?mode=ro"
    with sqlite3.connect(uri, uri=True) as connection:
        row = connection.execute("SELECT file FROM data ORDER BY _id LIMIT 1").fetchone()
    if not row:
        raise RuntimeError("settings database has no data row")
    value = row[0]
    if isinstance(value, bytes):
        value = value.decode("utf-8")
    parsed = json.loads(value)
    if not isinstance(parsed, dict):
        raise RuntimeError("settings data blob is not a JSON object")
    return parsed


def applications_by_id(settings: dict[str, Any]) -> dict[str, dict[str, Any]]:
    apps = settings.get("applications", {}).get("applications", [])
    return {app.get("applicationId"): app for app in apps if app.get("applicationId")}


def profile_label(profile: dict[str, Any], apps: dict[str, dict[str, Any]]) -> str:
    app = apps.get(profile.get("applicationId"), {})
    return app.get("name") or profile.get("name") or profile.get("applicationId", "<unknown>")


def assignments(profile: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {item.get("slotId"): item for item in profile.get("assignments", []) if item.get("slotId")}


def live_payload(assignment: dict[str, Any], shape: str) -> Any:
    card = assignment.get("card", {})
    if shape == "application_navigation":
        return card.get("nestedCards", {}).get("application_navigation")
    if shape == "thumb_direction":
        # The manifest's direction is supplied by the caller in compare().
        return card
    return card


def diff_line(path: str, expected: Any, actual: Any) -> str:
    return f"MISMATCH {path}:\n  expected: {canonical(expected)}\n  live:     {canonical(actual)}"


def compare(manifest: dict[str, Any], settings: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    device = manifest.get("device", {})
    prefix = device.get("slot_prefix")
    if not prefix:
        return ["manifest device.slot_prefix is missing"]

    expected_profiles = manifest.get("profiles", {})
    live_keys = settings.get("profile_keys", [])
    expected_ids = {item.get("profile_id") for item in expected_profiles.values()}
    live_ids = {settings.get(key, {}).get("id") for key in live_keys if isinstance(settings.get(key), dict)}
    if live_ids != expected_ids:
        for profile_id in sorted(expected_ids - live_ids):
            errors.append(f"MISSING PROFILE {profile_id}")
        for profile_id in sorted(live_ids - expected_ids):
            errors.append(f"ADDITIONAL PROFILE {profile_id}")

    apps = applications_by_id(settings)
    actions = manifest.get("actions", {})
    controls = manifest.get("controls", {})
    slot_for = {name: f"{prefix}_{suffix}" for name, suffix in controls.items()}
    settings_slots = {
        f"{prefix}_mouse_settings",
        f"{prefix}_mouse_scroll_wheel_settings",
        f"{prefix}_mouse_thumb_wheel_settings",
    }

    for profile_name, expected in expected_profiles.items():
        profile_id = expected.get("profile_id")
        live = settings.get(f"profile-{profile_id}")
        if not isinstance(live, dict):
            # Some Options+ versions use the profile id as the key without the prefix.
            live = next((settings.get(k) for k in live_keys if settings.get(k, {}).get("id") == profile_id), None)
        if not isinstance(live, dict):
            continue
        actual_label = profile_label(live, apps)
        actual_assignments = assignments(live)
        expected_assignments = expected.get("assignments", {})
        expected_slots = {slot_for[name] for name in expected_assignments if name in slot_for}
        actual_device_slots = {slot for slot in actual_assignments if slot.startswith(prefix + "_")}
        actual_slots = actual_device_slots & set(slot_for.values())
        for slot in sorted(expected_slots - actual_slots):
            errors.append(f"MISSING CONTROL {profile_name}/{slot}")
        for slot in sorted(actual_slots - expected_slots):
            errors.append(f"ADDITIONAL CONTROL {profile_name}/{slot}")
        for slot in sorted(actual_device_slots - expected_slots - settings_slots):
            if slot not in actual_slots:
                errors.append(f"ADDITIONAL CONTROL {profile_name}/{slot}")

        for control_name, action_name in expected_assignments.items():
            if control_name not in slot_for:
                errors.append(f"manifest has unknown control {control_name}")
                continue
            expected_action = actions.get(action_name)
            if not isinstance(expected_action, dict):
                errors.append(f"manifest action {action_name!r} is missing")
                continue
            slot = slot_for[control_name]
            assignment = actual_assignments.get(slot)
            if not assignment:
                continue
            shape = expected_action.get("shape", "card")
            actual = live_payload(assignment, shape)
            if shape == "thumb_direction":
                direction = expected_action.get("direction")
                actual = assignment.get("card", {}).get("nestedCards", {}).get(direction)
            expected_payload = expected_action.get("payload")
            if canonical(relevant(actual)) != canonical(relevant(expected_payload)):
                errors.append(diff_line(f"{actual_label}/{control_name} ({action_name})", expected_payload, actual))

    shared = manifest.get("shared_assignments", {})
    for control_name, action_name in shared.items():
        for profile_name, expected in expected_profiles.items():
            if expected.get("assignments", {}).get(control_name) != action_name:
                errors.append(f"SHARED ASSIGNMENT {control_name} differs in manifest profile {profile_name}")

    assertions = manifest.get("assertions", {})
    profile_count = assertions.get("expected_profile_count")
    if profile_count is not None and len(expected_profiles) != profile_count:
        errors.append(f"manifest profile count is {len(expected_profiles)}, expected {profile_count}")
    required = assertions.get("required_controls", [])
    for control in required:
        if control not in controls:
            errors.append(f"manifest assertion control {control!r} is not defined")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--database", type=Path, default=DEFAULT_DATABASE)
    args = parser.parse_args()
    try:
        manifest = load_json(args.manifest)
        if not isinstance(manifest, dict):
            raise RuntimeError("manifest is not a JSON object")
        settings = load_settings(args.database)
        errors = compare(manifest, settings)
    except (OSError, ValueError, json.JSONDecodeError, sqlite3.Error, RuntimeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2
    if errors:
        print("MX Master 3S audit: DRIFT DETECTED", file=sys.stderr)
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    print("MX Master 3S audit: OK, live Options+ assignments match the manifest")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

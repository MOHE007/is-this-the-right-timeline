#!/usr/bin/env python3
"""Static validation for the Demo2 Godot content contract.

This does not require Godot. It catches broken scene links, unknown effects,
unknown conditions, and missing art-slot metadata before a Godot editor run.
"""
from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data" / "ch1"


def load(name: str) -> dict:
    with (DATA / name).open(encoding="utf-8") as handle:
        return json.load(handle)


def main() -> int:
    content = load("demo2_ch1_content_v01.json")
    state = load("demo2_ch1_state_v01.json")
    manifest = load("demo2_ch1_manifest_v01.json")

    scene_ids = {scene["id"] for scene in content.get("scenes", [])}
    errors: list[str] = []
    if len(scene_ids) != 14:
        errors.append(f"expected 14 unique scenes, got {len(scene_ids)}")

    conditions = set(state.get("conditions", {}))
    effects = set(state.get("effects_catalog", {}))
    referenced_scenes: set[str] = set()
    referenced_effects: set[str] = set()
    referenced_conditions: set[str] = set()

    for scene in content.get("scenes", []):
        if not scene.get("visual"):
            errors.append(f"{scene.get('id')}: missing visual art slot")
        for beat in scene.get("beats", []):
            referenced_effects.update(beat.get("effects", []))
            for choice in beat.get("choices", []):
                target = choice.get("next_scene_id")
                if target:
                    referenced_scenes.add(target)
                if choice.get("condition"):
                    referenced_conditions.add(choice["condition"])
                composite = choice.get("conditions", {})
                for item in composite.get("all", []) if isinstance(composite, dict) else []:
                    if isinstance(item, str):
                        referenced_conditions.add(item)
                referenced_effects.update(choice.get("effects", []))

    missing_scenes = referenced_scenes - scene_ids
    missing_conditions = referenced_conditions - conditions
    missing_effects = referenced_effects - effects
    if missing_scenes:
        errors.append(f"unknown next_scene_id: {sorted(missing_scenes)}")
    if missing_conditions:
        errors.append(f"unknown condition: {sorted(missing_conditions)}")
    if missing_effects:
        errors.append(f"unknown effect: {sorted(missing_effects)}")

    manifest_ids = set(manifest.get("scene_ids", []))
    if manifest_ids != scene_ids:
        errors.append("manifest scene_ids do not match content scenes")

    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1

    print(f"OK: {len(scene_ids)} scenes, {len(referenced_effects)} effects, {len(referenced_conditions)} conditions")
    print("OK: art slot metadata present for every scene")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

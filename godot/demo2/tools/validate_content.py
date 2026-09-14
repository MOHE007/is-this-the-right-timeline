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
    state_patch = load("demo2_ch1_state_v02.json")
    content_patch = load("demo2_ch1_content_v02_patch.json")
    shan = load("demo2_ch1_shan_answers_v02.json")

    # Merge v02 the same way the runtime does (field-level scene merge).
    scenes_by_id = {scene["id"]: scene for scene in content.get("scenes", [])}
    for patch_scene in content_patch.get("scenes", []):
        base = scenes_by_id.get(patch_scene.get("id"))
        if base is None:
            print(f"ERROR: content v02 patch targets unknown scene {patch_scene.get('id')}")
            return 1
        base.update(patch_scene)

    scene_ids = set(scenes_by_id)
    errors: list[str] = []
    if len(scene_ids) != 14:
        errors.append(f"expected 14 unique scenes, got {len(scene_ids)}")

    conditions = set(state.get("conditions", {})) | set(state_patch.get("conditions_patch", {}))
    effects = set(state.get("effects_catalog", {})) | set(state_patch.get("effects_catalog_patch", {}))
    referenced_scenes: set[str] = set()
    referenced_effects: set[str] = set()
    referenced_conditions: set[str] = set()

    shan_prompts = set(shan.get("prompts", {}))
    investigation_objects = 0
    for scene in scenes_by_id.values():
        if not scene.get("visual"):
            errors.append(f"{scene.get('id')}: missing visual art slot")
        investigation = scene.get("investigation") or {}
        seen_object_ids: set[str] = set()
        for obj in investigation.get("objects", []):
            object_id = obj.get("id", "")
            if not object_id or not object_id.isascii():
                errors.append(f"{scene.get('id')}: bad investigation object id {object_id!r}")
            if object_id in seen_object_ids:
                errors.append(f"{scene.get('id')}: duplicate investigation object {object_id}")
            seen_object_ids.add(object_id)
            referenced_effects.update(e.split(":", 1)[0] for e in obj.get("effects", []))
            investigation_objects += 1
        for raw in investigation.get("leave_effects", []):
            if isinstance(raw, dict):
                referenced_effects.add(str(raw.get("effect", "")).split(":", 1)[0])
            else:
                referenced_effects.add(str(raw).split(":", 1)[0])
        for prompt in scene.get("shan_prompts", []):
            prompt_id = prompt.get("id") if isinstance(prompt, dict) else prompt
            if prompt_id not in shan_prompts:
                errors.append(f"{scene.get('id')}: unknown shan prompt {prompt_id}")
            if isinstance(prompt, dict):
                referenced_effects.update(e.split(":", 1)[0] for e in prompt.get("effects", []))
        for beat in scene.get("beats", []):
            referenced_effects.update(e.split(":", 1)[0] for e in beat.get("effects", []))
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
                referenced_effects.update(e.split(":", 1)[0] for e in choice.get("effects", []))

    for prompt_id, prompt in shan.get("prompts", {}).items():
        referenced_effects.update(e.split(":", 1)[0] for e in prompt.get("effects", []))
        for key in ("fact", "context", "counter_question"):
            if not prompt.get("answer", {}).get(key):
                errors.append(f"shan prompt {prompt_id}: missing answer.{key}")
        if not prompt.get("insufficient_text"):
            errors.append(f"shan prompt {prompt_id}: missing insufficient_text")

    # Named conditions referenced inside v02 condition groups must resolve.
    for name, group in state_patch.get("conditions_patch", {}).items():
        for item in group.get("all", []) if isinstance(group, dict) else []:
            if isinstance(item, str) and item not in conditions:
                errors.append(f"condition {name}: unknown sub-condition {item}")

    # nodes_patch health: ids should be real scenes; named entry conditions
    # must exist (undefined markers cannot be enforced by the runtime).
    warnings: list[str] = []
    for node in state_patch.get("nodes_patch", []):
        node_id = node.get("id", "")
        if node_id not in scene_ids:
            warnings.append(f"nodes_patch id {node_id!r} does not match any scene id")
        entry = node.get("entry_conditions", {})
        for key in ("all", "any"):
            for item in entry.get(key, []) if isinstance(entry, dict) else []:
                if isinstance(item, str) and item not in conditions:
                    warnings.append(f"nodes_patch {node_id}: undefined condition name {item!r}")

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

    for warning in warnings:
        print(f"WARN: {warning}")
    print(f"OK: {len(scene_ids)} scenes, {len(referenced_effects)} effects, {len(referenced_conditions)} conditions")
    print(f"OK: v02 merge — {investigation_objects} investigation objects, {len(shan_prompts)} shan prompts")
    print("OK: art slot metadata present for every scene")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

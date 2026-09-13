extends Control

# Demo2 placeholder runtime, exploration edition (v02 work package D+E).
#
# Contracts: v01 base + v02 patches are merged at load time.
#   - content v02 patch merges FIELD-LEVEL into v01 scenes (beats/year/visual
#     survive). The patch file says "replace scenes by id" but a literal
#     replace would drop beats; flagged to Codex for the v03 wording fix.
#   - state v02 patches initial_state / effects_catalog / conditions and adds
#     ending rules (divergent_ready_v02 / truth_ready_v02).
# Effects and conditions are interpreted from the merged catalog instead of
# being hardcoded, so contract changes no longer require code edits.

const CONTENT_PATH := "res://data/ch1/demo2_ch1_content_v01.json"
const CONTENT_PATCH_PATH := "res://data/ch1/demo2_ch1_content_v02_patch.json"
const STATE_PATH := "res://data/ch1/demo2_ch1_state_v01.json"
const STATE_PATCH_PATH := "res://data/ch1/demo2_ch1_state_v02.json"
const MANIFEST_PATH := "res://data/ch1/demo2_ch1_manifest_v01.json"
const SHAN_PATH := "res://data/ch1/demo2_ch1_shan_answers_v02.json"

const CLUE_NAMES := {
    "family_letter": "家书",
    "military_order": "军书",
    "route_map": "路线图",
    "civilian_testimony": "证言",
}
const FRAGMENT_NAMES := {
    "route_map_fragment": "路线碎片",
    "ferry_register": "船夫名册",
}

var content: Dictionary = {}
var contract: Dictionary = {}
var manifest: Dictionary = {}
var shan: Dictionary = {}
var effects_catalog: Dictionary = {}
var conditions_catalog: Dictionary = {}
var runtime: Dictionary = {}
var scenes_by_id: Dictionary = {}
var current_scene_id := "s01_modern_article"
var current_beat_index := 0
var waiting_for_choice := false
# Runtime-provided ordinary-closure bridge; exposed for smoke tests.
var fallback_choice: Dictionary = {}

var title_label: Label
var year_label: Label
var scene_label: Label
var visual_panel: ColorRect
var visual_title: Label
var invest_title: Label
var invest_box: VBoxContainer
var shan_title: Label
var shan_box: VBoxContainer
var dialogue_panel: PanelContainer
var speaker_label: Label
var dialogue_label: Label
var continue_button: Button
var choices_box: VBoxContainer
var status_label: Label
var clue_label: Label
var choice_hint_label: Label

func _ready() -> void:
    _load_contracts()
    _build_ui()
    _enter_scene(current_scene_id)

# ---------------------------------------------------------------- contracts

func _load_contracts() -> void:
    content = _read_json(CONTENT_PATH)
    contract = _read_json(STATE_PATH)
    manifest = _read_json(MANIFEST_PATH)
    shan = _read_json(SHAN_PATH)

    var state_patch := _read_json(STATE_PATCH_PATH)
    var initial: Dictionary = contract.get("initial_state", {}).duplicate(true)
    initial.merge(state_patch.get("initial_state_patch", {}), true)
    runtime = initial.duplicate(true)
    runtime["investigated_objects"] = {}
    runtime["shan_answered"] = []

    effects_catalog = contract.get("effects_catalog", {}).duplicate(true)
    effects_catalog.merge(state_patch.get("effects_catalog_patch", {}), true)
    conditions_catalog = contract.get("conditions", {}).duplicate(true)
    conditions_catalog.merge(state_patch.get("conditions_patch", {}), true)
    _apply_ending_rules(state_patch.get("ending_rules_patch", {}))

    for scene in content.get("scenes", []):
        scenes_by_id[scene.get("id", "")] = scene
    var content_patch := _read_json(CONTENT_PATCH_PATH)
    for patch_scene in content_patch.get("scenes", []):
        var sid := str(patch_scene.get("id", ""))
        if scenes_by_id.has(sid):
            var base: Dictionary = scenes_by_id[sid]
            for key in patch_scene.keys():
                base[key] = patch_scene[key]
        else:
            push_warning("content v02 patch targets unknown scene: " + sid)

    var manifest_scene_ids: Array = manifest.get("scene_ids", [])
    if not manifest_scene_ids.is_empty():
        for scene_id in scenes_by_id.keys():
            if scene_id not in manifest_scene_ids:
                push_warning("Scene missing from manifest: " + str(scene_id))

func _apply_ending_rules(rules: Dictionary) -> void:
    # ending_rules_patch: {"ending_divergent": "divergent_ready_v02", ...}
    # Legacy s11 buttons carry named conditions "<x>_ready"; alias them onto
    # the v02 gate so special endings need real verification (frozen rule 5).
    for ending_id in rules.keys():
        var legacy := str(ending_id).trim_prefix("ending_") + "_ready"
        var target := str(rules[ending_id])
        if conditions_catalog.has(legacy) and legacy != target and conditions_catalog.has(target):
            conditions_catalog[legacy] = {"all": [target]}

func _read_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Missing JSON: " + path)
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    return parsed if parsed is Dictionary else {}

# ----------------------------------------------------------------------- ui

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#10191d")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    visual_panel = ColorRect.new()
    visual_panel.color = Color("#24363b")
    visual_panel.position = Vector2(40, 34)
    visual_panel.size = Vector2(1200, 510)
    add_child(visual_panel)

    visual_title = Label.new()
    visual_title.position = Vector2(40, 40)
    visual_title.size = Vector2(1120, 100)
    visual_title.add_theme_font_size_override("font_size", 28)
    visual_title.add_theme_color_override("font_color", Color("#d5e2dc"))
    visual_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    visual_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    visual_panel.add_child(visual_title)

    invest_title = Label.new()
    invest_title.position = Vector2(26, 226)
    invest_title.size = Vector2(380, 24)
    invest_title.add_theme_font_size_override("font_size", 15)
    invest_title.add_theme_color_override("font_color", Color("#d9d0b8"))
    visual_panel.add_child(invest_title)

    invest_box = VBoxContainer.new()
    invest_box.position = Vector2(26, 254)
    invest_box.size = Vector2(380, 230)
    invest_box.add_theme_constant_override("separation", 6)
    visual_panel.add_child(invest_box)

    shan_title = Label.new()
    shan_title.position = Vector2(816, 226)
    shan_title.size = Vector2(360, 24)
    shan_title.add_theme_font_size_override("font_size", 15)
    shan_title.add_theme_color_override("font_color", Color("#8fb8c9"))
    visual_panel.add_child(shan_title)

    shan_box = VBoxContainer.new()
    shan_box.position = Vector2(816, 254)
    shan_box.size = Vector2(360, 230)
    shan_box.add_theme_constant_override("separation", 6)
    visual_panel.add_child(shan_box)

    title_label = Label.new()
    title_label.position = Vector2(62, 12)
    title_label.text = "这真的是对的时间线吗？  ·  Demo2 第一章 · 探索版"
    title_label.add_theme_font_size_override("font_size", 18)
    title_label.add_theme_color_override("font_color", Color("#d9d0b8"))
    add_child(title_label)

    year_label = Label.new()
    year_label.position = Vector2(1040, 12)
    year_label.size = Vector2(180, 28)
    year_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    year_label.add_theme_font_size_override("font_size", 18)
    year_label.add_theme_color_override("font_color", Color("#c78b6b"))
    add_child(year_label)

    scene_label = Label.new()
    scene_label.position = Vector2(62, 548)
    scene_label.size = Vector2(900, 24)
    scene_label.add_theme_font_size_override("font_size", 16)
    scene_label.add_theme_color_override("font_color", Color("#b9c7c1"))
    add_child(scene_label)

    dialogue_panel = PanelContainer.new()
    dialogue_panel.position = Vector2(40, 574)
    dialogue_panel.size = Vector2(820, 116)
    add_child(dialogue_panel)
    var dialogue_margin := MarginContainer.new()
    dialogue_margin.add_theme_constant_override("margin_left", 18)
    dialogue_margin.add_theme_constant_override("margin_right", 18)
    dialogue_margin.add_theme_constant_override("margin_top", 10)
    dialogue_margin.add_theme_constant_override("margin_bottom", 10)
    dialogue_panel.add_child(dialogue_margin)
    var dialogue_box := VBoxContainer.new()
    dialogue_margin.add_child(dialogue_box)
    speaker_label = Label.new()
    speaker_label.add_theme_color_override("font_color", Color("#d5a16b"))
    dialogue_box.add_child(speaker_label)
    dialogue_label = Label.new()
    dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    dialogue_label.add_theme_font_size_override("font_size", 16)
    dialogue_label.add_theme_color_override("font_color", Color("#edf0e9"))
    dialogue_box.add_child(dialogue_label)

    continue_button = Button.new()
    continue_button.text = "继续"
    continue_button.position = Vector2(880, 620)
    continue_button.size = Vector2(140, 52)
    continue_button.pressed.connect(_advance)
    add_child(continue_button)

    choices_box = VBoxContainer.new()
    choices_box.position = Vector2(880, 470)
    choices_box.size = Vector2(320, 130)
    choices_box.add_theme_constant_override("separation", 8)
    add_child(choices_box)

    choice_hint_label = Label.new()
    choice_hint_label.position = Vector2(880, 432)
    choice_hint_label.size = Vector2(340, 34)
    choice_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    choice_hint_label.add_theme_font_size_override("font_size", 12)
    choice_hint_label.add_theme_color_override("font_color", Color("#c78b6b"))
    add_child(choice_hint_label)

    clue_label = Label.new()
    clue_label.position = Vector2(62, 695)
    clue_label.size = Vector2(800, 20)
    clue_label.add_theme_font_size_override("font_size", 13)
    clue_label.add_theme_color_override("font_color", Color("#91aaa2"))
    add_child(clue_label)

    status_label = Label.new()
    status_label.position = Vector2(880, 695)
    status_label.size = Vector2(340, 20)
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    status_label.add_theme_font_size_override("font_size", 13)
    status_label.add_theme_color_override("font_color", Color("#91aaa2"))
    add_child(status_label)

# ------------------------------------------------------------------- scenes

func _enter_scene(scene_id: String) -> void:
    if not scenes_by_id.has(scene_id):
        _finish("缺少场景：" + scene_id)
        return
    if scene_id != current_scene_id:
        _apply_leave_effects(current_scene_id)
    current_scene_id = scene_id
    current_beat_index = 0
    runtime["current_scene_id"] = scene_id
    var scene: Dictionary = scenes_by_id[scene_id]
    runtime["year"] = int(scene.get("year", runtime.get("year", 2026)))
    _render_scene(scene)

func _apply_leave_effects(scene_id: String) -> void:
    # "remember_missed_clue:family_letter" fires only when the clue was
    # actually missed, and surfaces the scene's fallback_feedback.
    var scene: Dictionary = scenes_by_id.get(scene_id, {})
    var investigation: Dictionary = scene.get("investigation", {}) if scene.get("investigation") is Dictionary else {}
    var missed_any := false
    for raw in investigation.get("leave_effects", []):
        var parts := str(raw).split(":", true, 1)
        if parts[0] == "remember_missed_clue" and parts.size() == 2:
            if not _has_evidence(parts[1]):
                _apply_effect(raw)
                missed_any = true
        else:
            _apply_effect(str(raw))
    if missed_any:
        var feedback := str(scene.get("fallback_feedback", ""))
        if not feedback.is_empty():
            choice_hint_label.text = feedback

func _render_scene(scene: Dictionary) -> void:
    var beats: Array = scene.get("beats", [])
    if beats.is_empty():
        _finish("场景没有内容：" + current_scene_id)
        return
    var resource_id := str(manifest.get("scene_visuals", {}).get(current_scene_id, scene.get("visual", "art_slot")))
    visual_title.text = "占位画面\n" + resource_id
    scene_label.text = str(scene.get("title", current_scene_id)) + "   ·   scene_id: " + current_scene_id
    year_label.text = str(scene.get("year", ""))
    _render_investigation(scene)
    _render_shan(scene)
    _show_beat(beats[current_beat_index])

# ------------------------------------------------------ investigation panel

func _render_investigation(scene: Dictionary) -> void:
    _clear_children(invest_box)
    var investigation: Dictionary = scene.get("investigation", {}) if scene.get("investigation") is Dictionary else {}
    var objects: Array = investigation.get("objects", [])
    invest_title.text = "调查对象（点击拾取/查看）" if not objects.is_empty() else ""
    for object in objects:
        var object_id := str(object.get("id", ""))
        var done := _is_investigated(current_scene_id, object_id)
        var button := Button.new()
        button.text = ("✓ " if done else "◻ ") + str(object.get("label", object_id))
        button.custom_minimum_size = Vector2(380, 38)
        button.disabled = done and bool(object.get("once", true))
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.pressed.connect(_on_investigate_pressed.bind(object_id))
        invest_box.add_child(button)

func _on_investigate_pressed(object_id: String) -> void:
    investigate(object_id)

func investigate(object_id: String) -> bool:
    # Public for smoke tests. Applies the object's effects once.
    var scene: Dictionary = scenes_by_id.get(current_scene_id, {})
    var investigation: Dictionary = scene.get("investigation", {}) if scene.get("investigation") is Dictionary else {}
    for object in investigation.get("objects", []):
        if str(object.get("id", "")) != object_id:
            continue
        if _is_investigated(current_scene_id, object_id) and bool(object.get("once", true)):
            return false
        for effect in object.get("effects", []):
            _apply_effect(str(effect))
        var investigated: Dictionary = runtime.get("investigated_objects", {})
        var list: Array = investigated.get(current_scene_id, [])
        if object_id not in list:
            list.append(object_id)
        investigated[current_scene_id] = list
        runtime["investigated_objects"] = investigated
        var counts: Dictionary = runtime.get("investigation_counts", {})
        counts[current_scene_id] = int(counts.get(current_scene_id, 0)) + 1
        runtime["investigation_counts"] = counts
        choice_hint_label.text = "已记录：" + str(object.get("label", object_id))
        _render_investigation(scene)
        _render_shan(scene)
        _update_status()
        return true
    push_warning("Unknown investigation object: " + object_id)
    return false

func _is_investigated(scene_id: String, object_id: String) -> bool:
    var investigated: Dictionary = runtime.get("investigated_objects", {})
    return object_id in investigated.get(scene_id, [])

# ------------------------------------------------------------- shan panel

func _render_shan(scene: Dictionary) -> void:
    _clear_children(shan_box)
    var prompt_ids: Array = scene.get("shan_prompts", [])
    if prompt_ids.is_empty():
        shan_title.text = ""
        return
    shan_title.text = "刘看山 · 剩 %d 次验证" % int(runtime.get("shan_questions_left", 0))
    var prompts: Dictionary = shan.get("prompts", {})
    for prompt_id in prompt_ids:
        var prompt: Dictionary = prompts.get(str(prompt_id), {})
        if prompt.is_empty():
            push_warning("Unknown shan prompt: " + str(prompt_id))
            continue
        var answered: bool = str(prompt_id) in runtime.get("shan_answered", [])
        var button := Button.new()
        button.text = ("✓ " if answered else "？ ") + str(prompt.get("label", prompt_id))
        button.custom_minimum_size = Vector2(360, 38)
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.disabled = answered
        button.pressed.connect(_on_shan_pressed.bind(str(prompt_id)))
        shan_box.add_child(button)

func _on_shan_pressed(prompt_id: String) -> void:
    ask_shan(prompt_id)

func ask_shan(prompt_id: String) -> String:
    # Public for smoke tests. Returns answered | insufficient | exhausted.
    var prompt: Dictionary = shan.get("prompts", {}).get(prompt_id, {})
    if prompt.is_empty():
        push_warning("Unknown shan prompt: " + prompt_id)
        return "unknown"
    if int(runtime.get("shan_questions_left", 0)) <= 0:
        speaker_label.text = "刘看山"
        dialogue_label.text = str(shan.get("exhausted_text", "验证次数已用完。"))
        _update_status()
        return "exhausted"
    var has_evidence := false
    for requirement in prompt.get("requires_any", []):
        if _has_evidence(str(requirement)):
            has_evidence = true
            break
    speaker_label.text = "刘看山"
    if not has_evidence:
        # Spec: insufficient answers still consume the question budget.
        _apply_effect("consume_shan_question")
        dialogue_label.text = str(prompt.get("insufficient_text", "信息不足。先把东西找到，再来问我。"))
        _render_shan(scenes_by_id.get(current_scene_id, {}))
        _update_status()
        return "insufficient"
    for effect in prompt.get("effects", []):
        _apply_effect(str(effect))
    var answer: Dictionary = prompt.get("answer", {})
    dialogue_label.text = "%s\n%s\n%s" % [str(answer.get("fact", "")), str(answer.get("context", "")), str(answer.get("counter_question", ""))]
    var answered: Array = runtime.get("shan_answered", [])
    if prompt_id not in answered:
        answered.append(prompt_id)
    runtime["shan_answered"] = answered
    _render_shan(scenes_by_id.get(current_scene_id, {}))
    _update_status()
    return "answered"

func _has_evidence(id: String) -> bool:
    if id in runtime.get("clues_found", []):
        return true
    if id in runtime.get("clue_fragments", []):
        return true
    return _truthy(runtime.get(id))

# -------------------------------------------------------------------- beats

func _show_beat(beat: Dictionary) -> void:
    waiting_for_choice = false
    fallback_choice = {}
    for effect in beat.get("effects", []):
        _apply_effect(str(effect))
    speaker_label.text = str(beat.get("speaker", "旁白"))
    dialogue_label.text = str(beat.get("text", ""))
    continue_button.visible = true
    continue_button.disabled = false
    _clear_choices()
    var choices: Array = beat.get("choices", [])
    if not choices.is_empty():
        continue_button.visible = false
        waiting_for_choice = false
        for choice in choices:
            var available := _choice_available(choice)
            if available:
                waiting_for_choice = true
            var button := Button.new()
            button.text = str(choice.get("label", "继续"))
            button.custom_minimum_size = Vector2(320, 42)
            button.disabled = not available
            if not available:
                button.tooltip_text = "条件未满足：" + str(choice.get("condition", choice.get("conditions", "未知")))
            button.pressed.connect(_choose.bind(choice))
            choices_box.add_child(button)
        if not waiting_for_choice:
            _offer_fallback_route(choices)
    _update_status()

func _offer_fallback_route(choices: Array) -> void:
    # Frozen rule 4: missing evidence must not dead-end the player. When every
    # route button is locked, offer the "ordinary closure" bridge from the v02
    # clue matrix. Runtime-provided pending a content v03 node (flagged).
    var next_id := ""
    for choice in choices:
        var raw_next = choice.get("next_scene_id")
        if raw_next is String and not raw_next.is_empty():
            next_id = raw_next
            break
    if next_id.is_empty():
        continue_button.visible = true
        dialogue_label.text += "\n\n（当前条件未满足，请检查线索或状态。）"
        return
    dialogue_label.text += "\n\n你交出了自己知道的一切，但预警没有一条能可靠抵达的链。历史沿着原来的方向走。"
    var button := Button.new()
    button.text = "接受未能改写的结局"
    button.custom_minimum_size = Vector2(320, 42)
    var fallback := {
        "label": "接受未能改写的结局",
        "effects": ["fail_delivery", "set_ending_canonical"],
        "next_scene_id": next_id,
    }
    fallback_choice = fallback
    button.pressed.connect(_choose.bind(fallback))
    choices_box.add_child(button)
    waiting_for_choice = true

func _advance() -> void:
    if waiting_for_choice:
        return
    var scene: Dictionary = scenes_by_id[current_scene_id]
    var beats: Array = scene.get("beats", [])
    current_beat_index += 1
    if current_beat_index < beats.size():
        _show_beat(beats[current_beat_index])
    else:
        _finish("章节段落完成：" + current_scene_id)

func _choose(choice: Dictionary) -> void:
    if not _choice_available(choice):
        choice_hint_label.text = "当前条件未满足，先完成调查或选择另一条路线。"
        return
    for effect in choice.get("effects", []):
        _apply_effect(str(effect))
    # JSON null must mean "stay in scene"; str(null) would otherwise route to
    # a bogus "<null>" scene (seen in s14 terminal choice).
    var raw_next = choice.get("next_scene_id")
    var next_id: String = raw_next if raw_next is String else ""
    if next_id.is_empty():
        var scene: Dictionary = scenes_by_id[current_scene_id]
        var beats: Array = scene.get("beats", [])
        current_beat_index += 1
        if current_beat_index < beats.size():
            _show_beat(beats[current_beat_index])
        else:
            _finish("选择已记录")
    else:
        _enter_scene(next_id)

# --------------------------------------------------------------- conditions

func _choice_available(choice: Dictionary) -> bool:
    # JSON null must mean "no condition" (seen in s08 ask_fact).
    var raw_condition = choice.get("condition")
    var named: String = raw_condition if raw_condition is String else ""
    if not named.is_empty() and not _condition_named(named):
        return false
    var grouped = choice.get("conditions", null)
    if grouped is Dictionary and not _condition_group(grouped):
        return false
    return true

func _condition_named(name: String) -> bool:
    if conditions_catalog.has(name):
        return _condition_group(conditions_catalog[name])
    return _truthy(runtime.get(name))

func _condition_group(group: Dictionary) -> bool:
    if group.has("eq") or group.has("gte") or group.has("lte") or group.has("contains"):
        return _condition_expression(group)
    if group.has("all"):
        for item in group["all"]:
            if item is String and not _condition_named(item):
                return false
            if item is Dictionary and not _condition_group(item):
                return false
    if group.has("any"):
        var any_ok := false
        for item in group["any"]:
            if (item is String and _condition_named(item)) or (item is Dictionary and _condition_group(item)):
                any_ok = true
        if not any_ok:
            return false
    return true

func _condition_expression(expression: Dictionary) -> bool:
    if expression.has("eq"):
        var pair = expression["eq"]
        return pair is Array and pair.size() == 2 and runtime.get(str(pair[0])) == pair[1]
    if expression.has("gte"):
        var pair = expression["gte"]
        return pair is Array and pair.size() == 2 and float(_number_or_zero(runtime.get(str(pair[0])))) >= float(pair[1])
    if expression.has("lte"):
        var pair = expression["lte"]
        return pair is Array and pair.size() == 2 and float(_number_or_zero(runtime.get(str(pair[0])))) <= float(pair[1])
    if expression.has("contains"):
        var pair = expression["contains"]
        if not (pair is Array and pair.size() == 2):
            return false
        var haystack = runtime.get(str(pair[0]), [])
        return haystack is Array and pair[1] in haystack
    return false

# ------------------------------------------------------------------ effects

func _apply_effect(effect_string: String) -> void:
    # Supports "name" and "name:param" ($-placeholders take the param).
    var parts := effect_string.split(":", true, 1)
    var name := parts[0]
    var param := parts[1] if parts.size() > 1 else ""
    if name == "resolve_intervention_branch" and str(runtime.get("branch", "")) != "intervene":
        # Contract writes branch=intervene unconditionally, which would
        # overwrite the witness branch and dead-end s11. Pending contract v03.
        return
    var entry = effects_catalog.get(name)
    if entry == null:
        push_warning("Unknown effect ignored: " + effect_string)
        return
    if entry.has("set"):
        for key in entry["set"].keys():
            runtime[key] = _substitute(entry["set"][key], param)
    if entry.has("increment"):
        for key in entry["increment"].keys():
            runtime[key] = _number_or_zero(runtime.get(key)) + int(entry["increment"][key])
    if entry.has("decrement"):
        for key in entry["decrement"].keys():
            runtime[key] = max(0, _number_or_zero(runtime.get(key)) - int(entry["decrement"][key]))
    if entry.has("append_unique"):
        for key in entry["append_unique"].keys():
            var value = _substitute(entry["append_unique"][key], param)
            var list = runtime.get(key, [])
            if not (list is Array):
                list = []
            if value not in list:
                list.append(value)
            runtime[key] = list
    # v01 catalog hardcodes evidence_completeness per clue (1/2/3/4), which is
    # order-dependent; recompute from the actual clue count. Flagged to Codex.
    if entry.has("append_unique") and entry["append_unique"].has("clues_found"):
        runtime["evidence_completeness"] = runtime.get("clues_found", []).size()

func _substitute(value, param: String):
    if value is String and value.begins_with("$"):
        return param
    return value

func _number_or_zero(value) -> int:
    if value is int or value is float:
        return int(value)
    return 0

func _truthy(value) -> bool:
    if value is bool:
        return value
    if value == null:
        return false
    if value is int or value is float:
        return value != 0
    if value is String:
        return not value.is_empty()
    if value is Array:
        return not value.is_empty()
    return true

# ------------------------------------------------------------------- status

func _clear_choices() -> void:
    _clear_children(choices_box)

func _clear_children(node: Node) -> void:
    for child in node.get_children():
        child.queue_free()

func _update_status() -> void:
    var parts := PackedStringArray()
    for clue_id in CLUE_NAMES.keys():
        var state := "·"
        if clue_id in runtime.get("verified_clues", []):
            state = "◆已验证"
        elif clue_id in runtime.get("clues_found", []):
            state = "●待验证"
        parts.append(str(CLUE_NAMES[clue_id]) + state)
    var fragments: Array = runtime.get("clue_fragments", [])
    var fragment_text := ""
    if not fragments.is_empty():
        var names := PackedStringArray()
        for fragment_id in fragments:
            names.append(str(FRAGMENT_NAMES.get(fragment_id, fragment_id)))
        fragment_text = "   碎片：" + "、".join(names)
    var missed: Array = runtime.get("missed_critical_clues", [])
    var missed_text := ""
    if not missed.is_empty():
        var names := PackedStringArray()
        for missed_id in missed:
            names.append(str(CLUE_NAMES.get(missed_id, FRAGMENT_NAMES.get(missed_id, missed_id))))
        missed_text = "   错过：" + "、".join(names)
    clue_label.text = "  ".join(parts) + fragment_text + missed_text + "   ·   提问 %d · 信任 %d" % [int(runtime.get("inquiry_count", 0)), int(runtime.get("trust_military", 0))]

    # initial_state carries explicit JSON nulls for branch/ending_id.
    var ending_raw = runtime.get("ending_id")
    var ending: String = ending_raw if ending_raw is String else ""
    var branch_raw = runtime.get("branch")
    var branch: String = branch_raw if branch_raw is String else "canonical"
    if branch.is_empty():
        branch = "canonical"
    status_label.text = "探索版 · 问%d · %s%s" % [int(runtime.get("shan_questions_left", 0)), branch, (" · " + ending) if not ending.is_empty() else ""]

func _finish(message: String) -> void:
    waiting_for_choice = false
    _clear_choices()
    continue_button.visible = false
    speaker_label.text = "系统"
    var missed: Array = runtime.get("missed_critical_clues", [])
    var missed_line := ""
    if not missed.is_empty():
        var names := PackedStringArray()
        for missed_id in missed:
            names.append(str(CLUE_NAMES.get(missed_id, FRAGMENT_NAMES.get(missed_id, missed_id))))
        missed_line = "\n错过的关键线索：" + "、".join(names)
    dialogue_label.text = message + missed_line + "\n\nDemo2 探索版占位运行时；美术资源将通过 resource_id 接入。"
    _update_status()

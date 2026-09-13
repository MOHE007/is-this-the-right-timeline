extends Control

const CONTENT_PATH := "res://data/ch1/demo2_ch1_content_v01.json"
const STATE_PATH := "res://data/ch1/demo2_ch1_state_v01.json"
const MANIFEST_PATH := "res://data/ch1/demo2_ch1_manifest_v01.json"

var content: Dictionary = {}
var contract: Dictionary = {}
var manifest: Dictionary = {}
var runtime: Dictionary = {}
var scenes_by_id: Dictionary = {}
var current_scene_id := "s01_modern_article"
var current_beat_index := 0
var waiting_for_choice := false

var title_label: Label
var year_label: Label
var scene_label: Label
var visual_panel: ColorRect
var visual_title: Label
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

func _load_contracts() -> void:
    content = _read_json(CONTENT_PATH)
    contract = _read_json(STATE_PATH)
    manifest = _read_json(MANIFEST_PATH)
    runtime = contract.get("initial_state", {}).duplicate(true)
    for scene in content.get("scenes", []):
        scenes_by_id[scene.get("id", "")] = scene
    var manifest_scene_ids: Array = manifest.get("scene_ids", [])
    if not manifest_scene_ids.is_empty():
        for scene_id in scenes_by_id.keys():
            if scene_id not in manifest_scene_ids:
                push_warning("Scene missing from manifest: " + str(scene_id))

func _read_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Missing JSON: " + path)
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    return parsed if parsed is Dictionary else {}

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
    visual_title.position = Vector2(40, 60)
    visual_title.size = Vector2(1120, 100)
    visual_title.add_theme_font_size_override("font_size", 30)
    visual_title.add_theme_color_override("font_color", Color("#d5e2dc"))
    visual_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    visual_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    visual_panel.add_child(visual_title)

    title_label = Label.new()
    title_label.position = Vector2(62, 12)
    title_label.text = "这真的是对的时间线吗？  ·  Demo2 第一章"
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
    scene_label.position = Vector2(62, 565)
    scene_label.size = Vector2(900, 26)
    scene_label.add_theme_font_size_override("font_size", 16)
    scene_label.add_theme_color_override("font_color", Color("#b9c7c1"))
    add_child(scene_label)

    dialogue_panel = PanelContainer.new()
    dialogue_panel.position = Vector2(40, 600)
    dialogue_panel.size = Vector2(820, 90)
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
    dialogue_label.add_theme_font_size_override("font_size", 17)
    dialogue_label.add_theme_color_override("font_color", Color("#edf0e9"))
    dialogue_box.add_child(dialogue_label)

    continue_button = Button.new()
    continue_button.text = "继续"
    continue_button.position = Vector2(880, 620)
    continue_button.size = Vector2(140, 52)
    continue_button.pressed.connect(_advance)
    add_child(continue_button)

    choices_box = VBoxContainer.new()
    choices_box.position = Vector2(880, 490)
    choices_box.size = Vector2(320, 110)
    choices_box.add_theme_constant_override("separation", 8)
    add_child(choices_box)

    choice_hint_label = Label.new()
    choice_hint_label.position = Vector2(880, 455)
    choice_hint_label.size = Vector2(320, 32)
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

func _enter_scene(scene_id: String) -> void:
    if not scenes_by_id.has(scene_id):
        _finish("缺少场景：" + scene_id)
        return
    current_scene_id = scene_id
    current_beat_index = 0
    runtime["current_scene_id"] = scene_id
    var scene: Dictionary = scenes_by_id[scene_id]
    runtime["year"] = int(scene.get("year", runtime.get("year", 2026)))
    _render_scene(scene)

func _render_scene(scene: Dictionary) -> void:
    var beats: Array = scene.get("beats", [])
    if beats.is_empty():
        _finish("场景没有内容：" + current_scene_id)
        return
    var resource_id := str(manifest.get("scene_visuals", {}).get(current_scene_id, scene.get("visual", "art_slot")))
    visual_title.text = "占位画面\n" + resource_id
    scene_label.text = str(scene.get("title", current_scene_id)) + "   ·   scene_id: " + current_scene_id
    year_label.text = str(scene.get("year", ""))
    _show_beat(beats[current_beat_index])

func _show_beat(beat: Dictionary) -> void:
    waiting_for_choice = false
    for effect in beat.get("effects", []):
        _apply_effect(str(effect))
    speaker_label.text = str(beat.get("speaker", "旁白"))
    dialogue_label.text = str(beat.get("text", ""))
    continue_button.visible = true
    continue_button.disabled = false
    _clear_choices()
    choice_hint_label.text = ""
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
            # A content condition should never dead-end the player. Keep a
            # visible diagnostic and allow the integrator to spot bad data.
            continue_button.visible = true
            dialogue_label.text += "\n\n（当前条件未满足，请检查线索或状态。）"
    _update_status()

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
    var next_id := str(choice.get("next_scene_id", ""))
    if next_id.is_empty():
        # A terminal choice may still be followed by beats in the same scene
        # (the 1161 Xin Qiji entrance uses this for its final prompt).
        var scene: Dictionary = scenes_by_id[current_scene_id]
        var beats: Array = scene.get("beats", [])
        current_beat_index += 1
        if current_beat_index < beats.size():
            _show_beat(beats[current_beat_index])
        else:
            _finish("选择已记录")
    else:
        _enter_scene(next_id)

func _choice_available(choice: Dictionary) -> bool:
    var named := str(choice.get("condition", ""))
    if not named.is_empty() and not _condition_named(named):
        return false
    var grouped = choice.get("conditions", null)
    if grouped is Dictionary and not _condition_group(grouped):
        return false
    return true

func _condition_named(name: String) -> bool:
    match name:
        "always_after_1142": return int(runtime.get("year", 0)) >= 1142
        "information_chain_complete": return _has_clue("military_order") and _has_clue("route_map") and int(runtime.get("trust_military", 0)) >= 2
        "divergent_ready", "route_divergent": return str(runtime.get("branch", "")) == "intervene" and bool(runtime.get("warning_delivered", false))
        "truth_ready", "route_truth": return str(runtime.get("branch", "")) == "witness" and bool(runtime.get("testimony_saved", false)) and int(runtime.get("inquiry_count", 0)) >= 3
        "route_history_continues": return str(runtime.get("branch", "")) == "witness"
        "three_inquiry_types":
            var types: Array = runtime.get("inquiry_types", [])
            return int(runtime.get("inquiry_count", 0)) >= 3 and "fact" in types and "context" in types and "counterfactual" in types
        "all_four_clues": return int(runtime.get("evidence_completeness", 0)) >= 4
        _: return bool(runtime.get(name, false))

func _condition_group(group: Dictionary) -> bool:
    if group.has("all"):
        for item in group["all"]:
            if item is String and not _condition_named(item):
                return false
            if item is Dictionary and not _condition_expression(item):
                return false
    if group.has("any"):
        var any_ok := false
        for item in group["any"]:
            if (item is String and _condition_named(item)) or (item is Dictionary and _condition_expression(item)):
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
        return pair is Array and pair.size() == 2 and float(runtime.get(str(pair[0]), 0)) >= float(pair[1])
    if expression.has("lte"):
        var pair = expression["lte"]
        return pair is Array and pair.size() == 2 and float(runtime.get(str(pair[0]), 0)) <= float(pair[1])
    if expression.has("contains"):
        var pair = expression["contains"]
        return pair is Array and pair.size() == 2 and pair[1] in runtime.get(str(pair[0]), [])
    return false

func _has_clue(clue_id: String) -> bool:
    return clue_id in runtime.get("clues_found", [])

func _apply_effect(effect: String) -> void:
    match effect:
        "set_baby_state":
            runtime["year"] = 1122
            runtime["player_age"] = 2
        "reveal_fate":
            runtime["knows_yuefei_fate"] = true
        "advance_to_1127":
            runtime["year"] = 1127
            runtime["player_age"] = 7
        "advance_to_1141":
            runtime["year"] = 1141
        "advance_to_1142":
            runtime["year"] = 1142
        "advance_to_1161":
            runtime["year"] = 1161
            runtime["xinqiji_intro_seen"] = true
        "find_family_letter":
            _add_clue("family_letter")
        "find_route_map":
            _add_clue("route_map")
        "find_military_order":
            _add_clue("military_order")
        "hear_civilian_testimony":
            _add_clue("civilian_testimony")
            runtime["testimony_saved"] = true
        "ask_fact", "ask_context", "ask_counterfactual":
            runtime["inquiry_count"] = int(runtime.get("inquiry_count", 0)) + 1
            var inquiry_type := effect.trim_prefix("ask_")
            var inquiry_types: Array = runtime.get("inquiry_types", [])
            if inquiry_type not in inquiry_types:
                inquiry_types.append(inquiry_type)
            runtime["inquiry_types"] = inquiry_types
        "gain_military_trust":
            runtime["trust_military"] = int(runtime.get("trust_military", 0)) + 1
        "choose_intervene", "resolve_intervention_branch":
            runtime["branch"] = "intervene"
            runtime["intervention_attempted"] = true
        "choose_witness":
            runtime["branch"] = "witness"
        "choose_leave":
            runtime["continuation_choice"] = "leave"
        "choose_continue":
            runtime["continuation_choice"] = "continue"
        "deliver_warning":
            runtime["warning_delivered"] = true
            runtime["recall_delayed"] = true
        "save_testimony":
            runtime["testimony_saved"] = true
        "set_ending_canonical":
            runtime["ending_id"] = "ending_canonical"
        "set_ending_divergent":
            runtime["ending_id"] = "ending_divergent"
        "set_ending_truth":
            runtime["ending_id"] = "ending_truth"
        "_":
            pass

func _add_clue(clue_id: String) -> void:
    var clues: Array = runtime.get("clues_found", [])
    if clue_id not in clues:
        clues.append(clue_id)
        runtime["evidence_completeness"] = clues.size()
    runtime["clues_found"] = clues

func _clear_choices() -> void:
    for child in choices_box.get_children():
        child.queue_free()

func _update_status() -> void:
    clue_label.text = "线索 %d/4   ·   提问 %d   ·   信任 %d" % [int(runtime.get("evidence_completeness", 0)), int(runtime.get("inquiry_count", 0)), int(runtime.get("trust_military", 0))]
    var ending := str(runtime.get("ending_id", ""))
    var branch := str(runtime.get("branch", "canonical"))
    status_label.text = "占位运行时 · %s%s" % [branch, (" · " + ending) if not ending.is_empty() else ""]

func _finish(message: String) -> void:
    waiting_for_choice = false
    _clear_choices()
    continue_button.visible = false
    speaker_label.text = "系统"
    dialogue_label.text = message + "\n\nDemo2 Godot 占位运行时已加载 JSON；美术资源将通过 resource_id 接入。"
    _update_status()

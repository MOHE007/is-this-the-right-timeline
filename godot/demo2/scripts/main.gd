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
const SAVE_PATH := "user://demo2_ch1_save_v02.json"
const SHAN_SPRITE_ROOT := "res://assets/art/characters/liushan"
# Scenes where Liu Kanshan's sprite stays hidden (pre-awakening prologue).
const LIUSHAN_HIDDEN_SCENES := ["s01_modern_article", "s02_baby_home"]
# UI_INK_DIALOGUE_FRAME is 1600x360; ink border slice for the dialogue panel.
const DIALOGUE_SLICE := 110.0
const DIALOGUE_SLICE_Y := 80.0
const SHAN_ANIMATION_FRAMES := {
    "idle": 100,
    "question": 120,
    "reminder": 80,
}

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
const CONDITION_LABELS := {
    "route_verified": "路线经刘看山验证",
    "recall_recipient_found": "找到可靠接收者",
    "shan_answer_recall": "理解召回链",
    "testimony_interpreted": "证言经刘看山解读",
    "information_chain_complete": "信息链完整",
    "divergent_ready_v02": "偏离线四项验证",
    "truth_ready_v02": "真相线验证",
    "route_divergent": "介入线（已介入并交付预警）",
    "route_truth": "见证线（保存证言并提问三次）",
    "route_history_continues": "见证线",
    "always_after_1142": "到达 1142 年之后",
    "three_inquiry_types": "问过事实/背景/反事实",
    "all_four_clues": "集齐四类物证",
    "divergent_ready": "偏离线验证",
    "truth_ready": "真相线验证",
}

var content: Dictionary = {}
var contract: Dictionary = {}
var state_patch: Dictionary = {}
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
# Loading a save re-renders beats; their effects were already applied when the
# save was taken, so they must not fire again (e.g. s07 trust increment).
var suppress_beat_effects := false

var title_label: Label
var year_label: Label
var scene_label: Label
var visual_panel: ColorRect
var bg_texture: TextureRect
var char_portrait: TextureRect
var visual_title: Label
var invest_title: Label
var invest_box: VBoxContainer
var shan_title: Label
var shan_box: VBoxContainer
var shan_sprite: AnimatedSprite2D
var dialogue_panel: PanelContainer
var speaker_label: Label
var dialogue_label: Label
var continue_button: Button
var choices_box: VBoxContainer
var status_label: Label
var clue_label: Label
var choice_hint_label: Label
var save_button: Button
var load_button: Button

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

    state_patch = _read_json(STATE_PATCH_PATH)
    var initial: Dictionary = contract.get("initial_state", {}).duplicate(true)
    initial.merge(state_patch.get("initial_state_patch", {}), true)
    runtime = initial.duplicate(true)
    runtime["investigated_objects"] = {}
    runtime["shan_answered"] = []
    runtime["locked_groups"] = {}

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

# ------------------------------------------------------------------- assets

func _asset_path(resource_id: String) -> String:
    var bindings: Dictionary = manifest.get("assets", {}).get("bindings", {})
    var entry = bindings.get(resource_id)
    if entry is Dictionary:
        return str(entry.get("path", ""))
    return ""

func _load_asset(resource_id: String):
    var path := _asset_path(resource_id)
    if path.is_empty():
        return null
    if not ResourceLoader.exists(path):
        push_warning("Missing art asset: " + resource_id + " (" + path + ")")
        return null
    return load(path)

func _apply_dialogue_frame() -> void:
    # UI_INK_DIALOGUE_FRAME is 1600x360; slice the ink border so it scales.
    var texture = _load_asset(str(manifest.get("assets", {}).get("ui_bindings", {}).get("dialogue_frame", "UI_INK_DIALOGUE_FRAME")))
    if texture == null:
        return
    var style := StyleBoxTexture.new()
    style.texture = texture
    style.set_texture_margin_all(0)
    style.texture_margin_left = DIALOGUE_SLICE
    style.texture_margin_right = DIALOGUE_SLICE
    style.texture_margin_top = DIALOGUE_SLICE_Y
    style.texture_margin_bottom = DIALOGUE_SLICE_Y
    dialogue_panel.add_theme_stylebox_override("panel", style)

func _apply_scene_art() -> void:
    var resource_id := str(manifest.get("scene_visuals", {}).get(current_scene_id, ""))
    var texture = _load_asset(resource_id) if not resource_id.is_empty() else null
    if texture != null:
        bg_texture.texture = texture
        bg_texture.visible = true
        visual_title.visible = false
    else:
        bg_texture.visible = false
        visual_title.visible = true
        visual_title.text = "占位画面\n" + resource_id

func _apply_speaker_art(speaker: String) -> void:
    var speaker_map: Dictionary = manifest.get("assets", {}).get("character_by_speaker", {})
    var resource_id = speaker_map.get(speaker)
    if resource_id == null or str(resource_id).is_empty():
        char_portrait.visible = false
        if shan_sprite != null:
            shan_sprite.visible = false
        return
    if str(resource_id) == "CHAR_LIUSHAN_WHITE":
        # Liu Kanshan has the animated sprite instead of a still portrait.
        char_portrait.visible = false
        if shan_sprite != null and current_scene_id not in LIUSHAN_HIDDEN_SCENES:
            shan_sprite.visible = true
            _play_shan_animation("idle")
        return
    var texture = _load_asset(str(resource_id))
    if texture == null:
        char_portrait.visible = false
        return
    char_portrait.texture = texture
    char_portrait.visible = true
    if shan_sprite != null:
        shan_sprite.visible = false

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

    # Scene background art (manifest.scene_visuals -> assets.bindings).
    bg_texture = TextureRect.new()
    bg_texture.position = Vector2.ZERO
    bg_texture.size = visual_panel.size
    bg_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    bg_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    bg_texture.visible = false
    visual_panel.add_child(bg_texture)

    # Speaking character portrait, center stage.
    char_portrait = TextureRect.new()
    char_portrait.position = Vector2(432, 34)
    char_portrait.size = Vector2(336, 470)
    char_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    char_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    char_portrait.visible = false
    visual_panel.add_child(char_portrait)

    visual_title = Label.new()
    visual_title.position = Vector2(40, 40)
    visual_title.size = Vector2(1120, 100)
    visual_title.add_theme_font_size_override("font_size", 28)
    visual_title.add_theme_color_override("font_color", Color("#d5e2dc"))
    visual_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    visual_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    visual_panel.add_child(visual_title)

    _build_shan_sprite()

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

    save_button = Button.new()
    save_button.text = "存档"
    save_button.position = Vector2(830, 8)
    save_button.size = Vector2(90, 26)
    save_button.pressed.connect(_on_save_pressed)
    add_child(save_button)

    load_button = Button.new()
    load_button.text = "读档"
    load_button.position = Vector2(928, 8)
    load_button.size = Vector2(90, 26)
    load_button.disabled = not FileAccess.file_exists(SAVE_PATH)
    load_button.pressed.connect(_on_load_pressed)
    add_child(load_button)

    scene_label = Label.new()
    scene_label.position = Vector2(62, 548)
    scene_label.size = Vector2(900, 24)
    scene_label.add_theme_font_size_override("font_size", 16)
    scene_label.add_theme_color_override("font_color", Color("#b9c7c1"))
    add_child(scene_label)

    dialogue_panel = PanelContainer.new()
    dialogue_panel.position = Vector2(40, 574)
    dialogue_panel.size = Vector2(820, 116)
    _apply_dialogue_frame()
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

func _build_shan_sprite() -> void:
    var sprite_frames := SpriteFrames.new()
    sprite_frames.remove_animation("default")
    for animation_name in SHAN_ANIMATION_FRAMES.keys():
        sprite_frames.add_animation(animation_name)
        sprite_frames.set_animation_speed(animation_name, 20.0)
        sprite_frames.set_animation_loop(animation_name, animation_name == "idle")
        var frame_count := int(SHAN_ANIMATION_FRAMES[animation_name])
        for frame_index in range(1, frame_count + 1):
            var path := "%s/%s/%03d.png" % [SHAN_SPRITE_ROOT, animation_name, frame_index]
            var texture = load(path)
            if texture is Texture2D:
                sprite_frames.add_frame(animation_name, texture)
            else:
                push_warning("Missing Liu Kanshan animation frame: " + path)

    shan_sprite = AnimatedSprite2D.new()
    shan_sprite.sprite_frames = sprite_frames
    shan_sprite.position = Vector2(610, 320)
    shan_sprite.scale = Vector2(1.35, 1.35)
    shan_sprite.animation_finished.connect(_on_shan_animation_finished)
    shan_sprite.visible = false
    visual_panel.add_child(shan_sprite)
    _play_shan_animation("idle")

func _play_shan_animation(animation_name: String) -> void:
    if shan_sprite == null or not shan_sprite.sprite_frames.has_animation(animation_name):
        return
    shan_sprite.play(animation_name)

func _on_shan_animation_finished() -> void:
    if shan_sprite != null and shan_sprite.animation != "idle":
        _play_shan_animation("idle")

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
    # v0.2.1 format: {"effect": "remember_missed_clue_if_absent", "clue_id": X}
    # whose guard lives in the effects catalog. Legacy "effect:param" strings
    # keep the runtime-side missed check for compatibility.
    var scene: Dictionary = scenes_by_id.get(scene_id, {})
    var investigation: Dictionary = scene.get("investigation", {}) if scene.get("investigation") is Dictionary else {}
    var missed_any := false
    for raw in investigation.get("leave_effects", []):
        if raw is Dictionary:
            var name := str(raw.get("effect", ""))
            var param := str(raw.get("clue_id", raw.get("param", "")))
            if _apply_effect_named(name, param):
                missed_any = true
        else:
            var parts := str(raw).split(":", true, 1)
            if parts[0] == "remember_missed_clue" and parts.size() == 2:
                if not _has_evidence(parts[1]):
                    _apply_effect(str(raw))
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
    _apply_scene_art()
    shan_sprite.visible = current_scene_id not in LIUSHAN_HIDDEN_SCENES
    if shan_sprite.visible:
        _play_shan_animation("idle")
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
        var group_locked := _group_locked(object) and not done
        var button := Button.new()
        # Glyphs limited to what the bundled subset font carries (✓ ● ◆ · —).
        var prefix := "✓ " if done else ("— " if group_locked else "· ")
        button.text = prefix + str(object.get("label", object_id))
        button.custom_minimum_size = Vector2(380, 38)
        button.disabled = (done and bool(object.get("once", true))) or group_locked
        if group_locked:
            button.tooltip_text = "你已在此处做出取舍，机会不再。"
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.pressed.connect(_on_investigate_pressed.bind(object_id))
        invest_box.add_child(button)

func _group_locked(object: Dictionary) -> bool:
    # v0.2.1 exclusive_group: picking one object in the group forfeits the
    # others in the same scene (s06 testimony vs ferry register trade-off).
    var group := str(object.get("exclusive_group", ""))
    if group.is_empty():
        return false
    var locked: Dictionary = runtime.get("locked_groups", {})
    return group in locked.get(current_scene_id, [])

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
        if _group_locked(object) and not _is_investigated(current_scene_id, object_id):
            choice_hint_label.text = "你已在此处做出取舍，这个机会不再。"
            return false
        for effect in object.get("effects", []):
            _apply_effect(str(effect))
        var investigated: Dictionary = runtime.get("investigated_objects", {})
        var list: Array = investigated.get(current_scene_id, [])
        if object_id not in list:
            list.append(object_id)
        investigated[current_scene_id] = list
        runtime["investigated_objects"] = investigated
        var group := str(object.get("exclusive_group", ""))
        if not group.is_empty():
            var locked: Dictionary = runtime.get("locked_groups", {})
            var groups: Array = locked.get(current_scene_id, [])
            if group not in groups:
                groups.append(group)
            locked[current_scene_id] = groups
            runtime["locked_groups"] = locked
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
    var prompts := _scene_prompts(scene)
    if prompts.is_empty():
        shan_title.text = ""
        return
    shan_title.text = "刘看山 · 剩 %d 次验证" % int(runtime.get("shan_questions_left", 0))
    for prompt in prompts:
        var prompt_id := str(prompt.get("id", ""))
        var answered: bool = prompt_id in runtime.get("shan_answered", [])
        var button := Button.new()
        button.text = ("✓ " if answered else "？ ") + str(prompt.get("label", prompt_id))
        button.custom_minimum_size = Vector2(360, 38)
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.disabled = answered
        button.pressed.connect(_on_shan_pressed.bind(prompt_id))
        shan_box.add_child(button)

func _scene_prompts(scene: Dictionary) -> Array:
    # v0.2.1 content carries prompt OBJECTS {id, requires, effects}; the
    # answers library contributes label/answer/insufficient text. Legacy
    # string ids fall back to the library plus state prompt_effects.
    var out: Array = []
    var library: Dictionary = shan.get("prompts", {})
    var state_bindings: Dictionary = state_patch.get("prompt_effects", {})
    for raw in scene.get("shan_prompts", []):
        var prompt := {}
        var prompt_id := ""
        if raw is Dictionary:
            prompt_id = str(raw.get("id", ""))
            # Prompt requirements are explicitly OR semantics in the v0.2.2
            # content contract. Keep the legacy `requires` spelling as a
            # compatibility fallback for the other prompts.
            prompt["requires"] = raw.get("requires_any", raw.get("requires", []))
            prompt["effects"] = raw.get("effects", [])
        else:
            prompt_id = str(raw)
            prompt["requires"] = []
            prompt["effects"] = []
        var lib: Dictionary = library.get(prompt_id, {})
        var binding: Dictionary = state_bindings.get(prompt_id, {})
        if (prompt["requires"] as Array).is_empty():
            var fallback_requires = binding.get("requires", binding.get("requires_any", lib.get("requires_any", [])))
            prompt["requires"] = fallback_requires if fallback_requires is Array else []
        if (prompt["effects"] as Array).is_empty():
            var fallback_effects = lib.get("effects", [])
            prompt["effects"] = fallback_effects if fallback_effects is Array else []
        if lib.is_empty() and (prompt["effects"] as Array).is_empty():
            push_warning("Unknown shan prompt: " + prompt_id)
            continue
        prompt["id"] = prompt_id
        prompt["label"] = str(lib.get("label", prompt_id))
        prompt["answer"] = lib.get("answer", {})
        prompt["insufficient_text"] = str(lib.get("insufficient_text", "信息不足。先把东西找到，再来问我。"))
        out.append(prompt)
    return out

func _on_shan_pressed(prompt_id: String) -> void:
    ask_shan(prompt_id)

func ask_shan(prompt_id: String) -> String:
    # Public for smoke tests. Returns answered | insufficient | exhausted.
    var prompt := {}
    for candidate in _scene_prompts(scenes_by_id.get(current_scene_id, {})):
        if str(candidate.get("id", "")) == prompt_id:
            prompt = candidate
            break
    if prompt.is_empty():
        push_warning("Unknown shan prompt: " + prompt_id)
        return "unknown"
    if int(runtime.get("shan_questions_left", 0)) <= 0:
        _play_shan_animation("reminder")
        speaker_label.text = "刘看山"
        dialogue_label.text = str(shan.get("exhausted_text", "验证次数已用完。"))
        _update_status()
        return "exhausted"
    var has_evidence := false
    for requirement in prompt.get("requires", []):
        if _has_evidence(str(requirement)):
            has_evidence = true
            break
    speaker_label.text = "刘看山"
    if not has_evidence:
        _play_shan_animation("reminder")
        # Spec: insufficient answers still consume the question budget (only
        # the consume effect fires — no ask_*, no verify_*).
        _apply_effect("consume_shan_question")
        dialogue_label.text = str(prompt.get("insufficient_text", ""))
        _render_shan(scenes_by_id.get(current_scene_id, {}))
        _update_status()
        return "insufficient"
    _play_shan_animation("question")
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
    if not suppress_beat_effects:
        for effect in beat.get("effects", []):
            _apply_effect(str(effect))
    speaker_label.text = str(beat.get("speaker", "旁白"))
    _apply_speaker_art(str(beat.get("speaker", "旁白")))
    dialogue_label.text = str(beat.get("text", ""))
    continue_button.visible = true
    continue_button.disabled = false
    _clear_choices()
    var choices: Array = beat.get("choices", [])
    if not choices.is_empty():
        continue_button.visible = false
        waiting_for_choice = false
        var first_locked_hint := ""
        for choice in choices:
            var available := _choice_available(choice)
            if available:
                waiting_for_choice = true
            var button := Button.new()
            button.text = str(choice.get("label", "继续"))
            button.custom_minimum_size = Vector2(320, 42)
            button.disabled = not available
            if not available:
                # N7: tell the player exactly which evidence link is missing
                # instead of a silent locked button.
                var missing := _failures_for_choice(choice)
                var missing_text := "、".join(missing) if not missing.is_empty() else "条件未满足"
                button.tooltip_text = "还缺：" + missing_text
                if first_locked_hint.is_empty():
                    first_locked_hint = "『%s』还缺：%s" % [str(choice.get("label", "")), missing_text]
            button.pressed.connect(_choose.bind(choice))
            choices_box.add_child(button)
        if not first_locked_hint.is_empty():
            choice_hint_label.text = first_locked_hint
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
    # v0.2.1 contract declares the fallback ending explicitly.
    var fallback_ending := str(state_patch.get("fallback", {}).get("ending", "ending_canonical"))
    var button := Button.new()
    button.text = "接受未能改写的结局"
    button.custom_minimum_size = Vector2(320, 42)
    var fallback := {
        "label": "接受未能改写的结局",
        "effects": ["fail_delivery", "set_" + fallback_ending],
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

func _failures_for_choice(choice: Dictionary) -> PackedStringArray:
    # N7: collect the unmet leaves of a locked choice's gate so the player
    # sees which evidence link is missing.
    var out := PackedStringArray()
    var raw_condition = choice.get("condition")
    if raw_condition is String and not raw_condition.is_empty():
        _collect_failures_named(raw_condition, out)
    var grouped = choice.get("conditions", null)
    if grouped is Dictionary:
        _collect_failures_group(grouped, out)
    return out

func _collect_failures_named(name: String, out: PackedStringArray) -> void:
    if _condition_named(name):
        return
    if conditions_catalog.has(name):
        var group = conditions_catalog[name]
        if group is Dictionary and group.has("all"):
            var before := out.size()
            _collect_failures_group(group, out)
            if out.size() > before:
                return
    var label := str(CONDITION_LABELS.get(name, name))
    if label not in out:
        out.append(label)

func _collect_failures_group(group: Dictionary, out: PackedStringArray) -> void:
    if group.has("eq") or group.has("gte") or group.has("lte") or group.has("contains"):
        if not _condition_expression(group):
            var label := _expression_label(group)
            if label not in out:
                out.append(label)
        return
    for item in group.get("all", []):
        if item is String:
            _collect_failures_named(item, out)
        elif item is Dictionary:
            _collect_failures_group(item, out)

func _expression_label(expression: Dictionary) -> String:
    if expression.has("contains"):
        var pair = expression["contains"]
        if pair is Array and pair.size() == 2:
            var value := str(pair[1])
            return "拾取" + str(CLUE_NAMES.get(value, FRAGMENT_NAMES.get(value, value)))
    if expression.has("gte"):
        var pair = expression["gte"]
        if pair is Array and pair.size() == 2:
            match str(pair[0]):
                "evidence_completeness": return "物证 ≥ %s" % str(pair[1])
                "inquiry_count": return "提问 ≥ %s" % str(pair[1])
                "trust_military": return "军中信任 ≥ %s" % str(pair[1])
                "year": return "到达 %s 年" % str(pair[1])
            return "%s ≥ %s" % [str(pair[0]), str(pair[1])]
    if expression.has("lte"):
        var pair = expression["lte"]
        if pair is Array and pair.size() == 2:
            if str(pair[0]) == "knowledge_debt":
                return "知识债 ≤ %s" % str(pair[1])
            return "%s ≤ %s" % [str(pair[0]), str(pair[1])]
    if expression.has("eq"):
        var pair = expression["eq"]
        if pair is Array and pair.size() == 2:
            var key := str(pair[0])
            match key:
                "branch": return "选择介入路线" if str(pair[1]) == "intervene" else "选择见证路线"
                "warning_delivered": return "交付预警"
                "recall_delayed": return "召回被延迟"
                "testimony_saved": return "保存证言"
                "route_verified": return "路线经刘看山验证"
                "recall_recipient_found": return "找到可靠接收者"
                "shan_answer_recall": return "理解召回链"
                "testimony_interpreted": return "证言经刘看山解读"
            return str(CONDITION_LABELS.get(key, key))
    return "条件未满足"

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
    _apply_effect_named(parts[0], parts[1] if parts.size() > 1 else "")

func _apply_effect_named(name: String, param: String) -> bool:
    # Returns true when the effect actually applied (guards may skip it).
    if name == "resolve_intervention_branch" and str(runtime.get("branch", "")) != "intervene":
        # Contract writes branch=intervene unconditionally, which would
        # overwrite the witness branch and dead-end s11. Pending contract v03.
        return false
    var entry = effects_catalog.get(name)
    if entry == null:
        push_warning("Unknown effect ignored: " + name)
        return false
    if entry.has("guard") and not _guard_passes(entry["guard"], param):
        return false
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
    # field_mapping: evidence_completeness is derived from the four canonical
    # physical clues actually held (v0.2.1 formula).
    if entry.has("append_unique") and entry["append_unique"].has("clues_found"):
        var count := 0
        for clue_id in CLUE_NAMES.keys():
            if clue_id in runtime.get("clues_found", []):
                count += 1
        runtime["evidence_completeness"] = count
    return true

func _guard_passes(guard: Dictionary, param: String) -> bool:
    if guard.has("not_contains"):
        var pair = guard["not_contains"]
        if pair is Array and pair.size() == 2:
            var list = runtime.get(str(pair[0]), [])
            var value = _substitute(pair[1], param)
            if list is Array and value in list:
                return false
            # Contract gap (reported as D2): recall_recipient_token is a
            # boolean flag and never enters clues_found, so the raw guard
            # would mark it missed even when held. Honor the intent via the
            # wider evidence check.
            if str(pair[0]) == "clues_found" and _has_evidence(str(value)):
                return false
            return true
    if guard.has("contains"):
        var pair = guard["contains"]
        if pair is Array and pair.size() == 2:
            var list = runtime.get(str(pair[0]), [])
            var value = _substitute(pair[1], param)
            return list is Array and value in list
    return true

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
    _show_ending_eggs()
    _update_status()

# -------------------------------------------------------------- easter eggs

func _show_ending_eggs() -> void:
    # Owner-approved closing easter eggs: interactive Yuefei/Xinqiji cards and
    # the credits avatars. Config lives in manifest.easter_eggs so the card
    # URLs can switch from localhost to the deployed host without code edits.
    var ending_raw = runtime.get("ending_id")
    if not (ending_raw is String) or (ending_raw as String).is_empty():
        return
    var eggs: Dictionary = manifest.get("easter_eggs", {})
    if eggs.is_empty():
        return
    # The closing line is the thematic payoff — it owns the dialogue box.
    speaker_label.text = "刘看山"
    var missed: Array = runtime.get("missed_critical_clues", [])
    var missed_line := ""
    if not missed.is_empty():
        var names := PackedStringArray()
        for missed_id in missed:
            names.append(str(CLUE_NAMES.get(missed_id, FRAGMENT_NAMES.get(missed_id, missed_id))))
        missed_line = "\n（这一周目错过：" + "、".join(names) + "）"
    dialogue_label.text = str(eggs.get("closing_line", "")) + missed_line
    _clear_children(invest_box)
    _clear_children(shan_box)
    shan_title.text = ""
    invest_title.text = "制作组彩蛋"
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 28)
    invest_box.add_child(row)
    for credit in eggs.get("credits", []):
        var card := VBoxContainer.new()
        card.add_theme_constant_override("separation", 6)
        var portrait := TextureRect.new()
        var texture = load(str(credit.get("path", "")))
        if texture:
            portrait.texture = texture
        portrait.custom_minimum_size = Vector2(128, 128)
        portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        card.add_child(portrait)
        var name_label := Label.new()
        name_label.text = "%s · %s" % [str(credit.get("name", "")), str(credit.get("role", ""))]
        name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        name_label.add_theme_font_size_override("font_size", 14)
        name_label.add_theme_color_override("font_color", Color("#d9d0b8"))
        card.add_child(name_label)
        row.add_child(card)
    for card_config in eggs.get("cards", []):
        var button := Button.new()
        button.text = "彩蛋 · " + str(card_config.get("label", ""))
        button.custom_minimum_size = Vector2(320, 42)
        button.pressed.connect(_open_card.bind(str(card_config.get("url", ""))))
        choices_box.add_child(button)

func _open_card(url: String) -> void:
    # OS.shell_open opens the default browser on desktop and a new tab on the
    # Web export (button press counts as the required user gesture).
    if url.is_empty():
        return
    OS.shell_open(url)
    choice_hint_label.text = "彩蛋卡片已在浏览器打开"

# -------------------------------------------------------------- save points

func _on_save_pressed() -> void:
    if save_game():
        choice_hint_label.text = "已存档：%s · beat %d" % [current_scene_id, current_beat_index]
        load_button.disabled = false

func _on_load_pressed() -> void:
    if load_game():
        choice_hint_label.text = "已读档：%s · beat %d" % [current_scene_id, current_beat_index]

func save_game() -> bool:
    # Public for smoke tests. Persists the full runtime state dictionary plus
    # the exact scene/beat cursor; only plain JSON crosses the boundary.
    var payload := {
        "schema_version": "1.0",
        "save_id": "demo2_ch1_v02",
        "timestamp": Time.get_datetime_string_from_system(),
        "current_scene_id": current_scene_id,
        "current_beat_index": current_beat_index,
        "runtime": runtime,
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        push_error("Cannot write save file: " + SAVE_PATH)
        return false
    file.store_string(JSON.stringify(payload, "  "))
    return true

func load_game() -> bool:
    # Public for smoke tests. Restores runtime and re-renders the saved beat.
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        push_warning("No save file: " + SAVE_PATH)
        return false
    var parsed = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary) or not (parsed.get("runtime") is Dictionary):
        push_error("Corrupt save file: " + SAVE_PATH)
        return false
    var scene_id := str(parsed.get("current_scene_id", ""))
    if not scenes_by_id.has(scene_id):
        push_error("Save references unknown scene: " + scene_id)
        return false
    runtime = (parsed["runtime"] as Dictionary).duplicate(true)
    current_scene_id = scene_id
    current_beat_index = 0
    # Beat effects already applied before the save; do not fire them again.
    suppress_beat_effects = true
    var scene: Dictionary = scenes_by_id[scene_id]
    _render_scene(scene)
    var beats: Array = scene.get("beats", [])
    var saved_beat := int(parsed.get("current_beat_index", 0))
    if saved_beat > 0 and saved_beat < beats.size():
        current_beat_index = saved_beat
        _show_beat(beats[saved_beat])
    suppress_beat_effects = false
    return true

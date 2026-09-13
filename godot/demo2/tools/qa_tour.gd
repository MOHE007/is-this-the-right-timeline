extends Node

# QA tour: auto-plays the verified truth route (investigation + Shan Q&A)
# while Movie Maker records frames.
#
#   godot --path . --write-movie /tmp/demo2_tour/frame.png --fixed-fps 10 res://tools/qa_tour.tscn
#
# One action is taken every ACTION_INTERVAL frames so each rendered state is
# visible for a moment in the captured sequence.

const ACTION_INTERVAL := 6
const MAX_ACTIONS := 90

var prefer := {
	"s05_station": "询问送信路线",
	"s06_ferry": "保存证言",
	"s09_recall_chain": "先帮助迁徙者并保存证言",
	"s11_outcome_router": "查看见证者真相线",
	"s12_leave_or_continue": "继续游戏，见证并帮助辛弃疾",
}
var investigate := {
	"s05_station": ["station_letter", "old_station_plate", "old_postman"],
	"s06_ferry": ["migrant_witness", "ferry_register"],
	"s07_military_town": ["military_order", "recall_recipient_token", "military_companion"],
}
var shan := {
	"s05_station": ["route_explain"],
	"s06_ferry": ["testimony_meaning"],
}

var main: Control
var frame_count := 0
var actions := 0
var pending: Array = []
var processed_scenes: Array = []

func _ready() -> void:
	main = (load("res://main.tscn") as PackedScene).instantiate()
	add_child(main)

func _process(_delta: float) -> void:
	frame_count += 1
	if frame_count % ACTION_INTERVAL != 0:
		return
	actions += 1
	if actions > MAX_ACTIONS:
		get_tree().quit()
		return
	var scene_id: String = main.current_scene_id
	if scene_id not in processed_scenes:
		processed_scenes.append(scene_id)
		for object_id in investigate.get(scene_id, []):
			pending.append(["investigate", str(object_id)])
		for prompt_id in shan.get(scene_id, []):
			pending.append(["shan", str(prompt_id)])
	if not pending.is_empty():
		var action: Array = pending.pop_front()
		if action[0] == "investigate":
			main.investigate(action[1])
		else:
			main.ask_shan(action[1])
		print("TOUR %s %s scene=%s" % [action[0], action[1], scene_id])
		return
	var scene: Dictionary = main.scenes_by_id.get(scene_id, {})
	var beats: Array = scene.get("beats", [])
	if main.current_beat_index >= beats.size():
		get_tree().quit()
		return
	var beat: Dictionary = beats[main.current_beat_index]
	var choices: Array = beat.get("choices", [])
	var before_scene: String = main.current_scene_id
	var before_beat: int = main.current_beat_index
	if choices.is_empty():
		if not main.continue_button.visible:
			get_tree().quit()
			return
		main._advance()
	else:
		var choice = _pick_choice(choices, prefer.get(before_scene, ""))
		if choice == null and not main.fallback_choice.is_empty():
			choice = main.fallback_choice
		if choice == null:
			push_error("QA tour dead end at %s beat %d" % [before_scene, before_beat])
			get_tree().quit()
			return
		main._choose(choice)
		if main.current_scene_id == before_scene and main.current_beat_index == before_beat:
			push_error("QA tour stalled at %s beat %d" % [before_scene, before_beat])
			get_tree().quit()
			return
	print("TOUR action=%d scene=%s beat=%d" % [actions, main.current_scene_id, main.current_beat_index])

func _pick_choice(choices: Array, preferred_label: String):
	if not preferred_label.is_empty():
		for choice in choices:
			if str(choice.get("label", "")) == preferred_label and main._choice_available(choice):
				return choice
	for choice in choices:
		if main._choice_available(choice):
			return choice
	return null

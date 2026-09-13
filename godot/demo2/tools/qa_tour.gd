extends Node

# QA tour: auto-plays the truth route while Movie Maker records frames.
#
#   godot --path . --write-movie /tmp/demo2_tour/frame.png --fixed-fps 10 res://tools/qa_tour.tscn
#
# One action is taken every ACTION_INTERVAL frames so each rendered state is
# visible for a moment in the captured sequence.

const ACTION_INTERVAL := 6
const MAX_ACTIONS := 60

var prefer := {
	"s05_station": "询问送信路线",
	"s06_ferry": "保存证言",
	"s09_recall_chain": "先帮助迁徙者并保存证言",
	"s11_outcome_router": "查看见证者真相线",
	"s12_leave_or_continue": "继续游戏，见证并帮助辛弃疾",
}

var main: Control
var frame_count := 0
var actions := 0

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
	var scene: Dictionary = main.scenes_by_id.get(main.current_scene_id, {})
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

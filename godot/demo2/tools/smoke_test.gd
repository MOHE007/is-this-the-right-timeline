extends SceneTree

# Headless smoke test for the Demo2 placeholder runtime.
#
#   godot --headless --path . -s res://tools/smoke_test.gd
#
# Drives main.tscn through the three ending routes by picking choices the way
# a player would, then asserts the reached ending_id. No rendering required.

const MAIN_SCENE := "res://main.tscn"
const MAX_STEPS := 200

var routes := {
	"divergent": {
		"prefer": {
			"s05_station": "记下老驿卒的证言",
			"s06_ferry": "只记录路线",
			"s07_military_town": "追问执行能力",
			"s09_recall_chain": "把预警交给军中接收者",
			"s11_outcome_router": "查看偏离但未改写",
			"s12_leave_or_continue": "直接进入下一章",
		},
		"expect_ending": "ending_divergent",
	},
	"canonical": {
		"prefer": {
			"s09_recall_chain": "先帮助迁徙者并保存证言",
			"s11_outcome_router": "查看历史轨迹",
			"s12_leave_or_continue": "直接进入下一章",
		},
		"expect_ending": "ending_canonical",
	},
	"truth": {
		"prefer": {
			"s05_station": "询问送信路线",
			"s06_ferry": "保存证言",
			"s09_recall_chain": "先帮助迁徙者并保存证言",
			"s11_outcome_router": "查看见证者真相线",
			"s12_leave_or_continue": "继续游戏，见证并帮助辛弃疾",
		},
		"expect_ending": "ending_truth",
	},
}

func _initialize() -> void:
	var failures := 0
	for route_name in routes.keys():
		if not await _run_route(route_name, routes[route_name]):
			failures += 1
	if failures == 0:
		print("SMOKE OK: 3/3 routes reached their expected endings")
	else:
		print("SMOKE FAILED: %d route(s) failed" % failures)
	quit(failures)

func _run_route(route_name: String, route: Dictionary) -> bool:
	var main = (load(MAIN_SCENE) as PackedScene).instantiate()
	root.add_child(main)
	await process_frame
	var trail: Array = [main.current_scene_id]
	var steps := 0
	var finished := false
	while steps < MAX_STEPS:
		steps += 1
		var scene: Dictionary = main.scenes_by_id.get(main.current_scene_id, {})
		var beats: Array = scene.get("beats", [])
		if main.current_beat_index >= beats.size():
			finished = true
			break
		var beat: Dictionary = beats[main.current_beat_index]
		var choices: Array = beat.get("choices", [])
		var before_scene: String = main.current_scene_id
		var before_beat: int = main.current_beat_index
		if choices.is_empty():
			if not main.continue_button.visible:
				finished = true
				break
			main._advance()
		else:
			var choice = _pick_choice(main, choices, route.get("prefer", {}).get(before_scene, ""))
			if choice == null:
				print("ROUTE %s: DEAD END at %s beat %d (no available choice)" % [route_name, before_scene, before_beat])
				main.queue_free()
				await process_frame
				return false
			main._choose(choice)
			if main.current_scene_id == before_scene and main.current_beat_index == before_beat:
				print("ROUTE %s: STALLED at %s beat %d (choice made no progress)" % [route_name, before_scene, before_beat])
				main.queue_free()
				await process_frame
				return false
		if main.current_scene_id != before_scene:
			trail.append(main.current_scene_id)
		elif main.current_scene_id == before_scene and main.current_beat_index == before_beat and choices.is_empty():
			finished = true
			break
	var ending := str(main.runtime.get("ending_id", ""))
	var expected := str(route.get("expect_ending", ""))
	var ok := ending == expected and finished
	print("ROUTE %s: %s | ending=%s expected=%s | steps=%d" % [route_name, "OK" if ok else "FAILED", ending, expected, steps])
	print("  trail: %s" % " -> ".join(PackedStringArray(trail)))
	print("  state: clues=%d inquiries=%d trust=%d branch=%s" % [int(main.runtime.get("evidence_completeness", 0)), int(main.runtime.get("inquiry_count", 0)), int(main.runtime.get("trust_military", 0)), str(main.runtime.get("branch", ""))])
	main.queue_free()
	await process_frame
	return ok

func _pick_choice(main, choices: Array, preferred_label: String):
	if not preferred_label.is_empty():
		for choice in choices:
			if str(choice.get("label", "")) == preferred_label and main._choice_available(choice):
				return choice
	for choice in choices:
		if main._choice_available(choice):
			return choice
	return null

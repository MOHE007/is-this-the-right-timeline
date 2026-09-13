extends SceneTree

# Headless smoke test for the Demo2 exploration runtime (v02).
#
#   godot --headless --path . -s res://tools/smoke_test.gd
#
# Five QA paths from the v02 work breakdown:
#   1. divergent_verified   full three-layer evidence -> ending_divergent
#   2. divergent_unverified evidence without Shan verification must NOT enter
#                           ending_divergent; ordinary closure, no deadlock
#   3. truth_verified       four clues + interpreted testimony -> ending_truth
#   4. canonical_missed     skip investigation; missed clues recorded; canonical
#   5. exhausted_questions  burn the budget on insufficient answers; no deadlock

const MAIN_SCENE := "res://main.tscn"
const MAX_STEPS := 300

var routes := {
	"divergent_verified": {
		"prefer": {
			"s05_station": "记下老驿卒的证言",
			"s06_ferry": "只记录路线",
			"s07_military_town": "追问执行能力",
			"s09_recall_chain": "把预警交给军中接收者",
			"s11_outcome_router": "查看偏离但未改写",
			"s12_leave_or_continue": "直接进入下一章",
		},
		"investigate": {
			"s05_station": ["old_station_plate", "old_postman"],
			"s07_military_town": ["military_order", "recall_recipient_token", "military_companion"],
		},
		"shan": {
			"s05_station": ["route_explain"],
			"s07_military_town": ["recall_chain"],
		},
		"expect_ending": "ending_divergent",
	},
	"divergent_unverified": {
		"prefer": {
			"s05_station": "记下老驿卒的证言",
			"s06_ferry": "只记录路线",
			"s07_military_town": "追问执行能力",
			"s09_recall_chain": "把预警交给军中接收者",
			"s12_leave_or_continue": "直接进入下一章",
		},
		"investigate": {
			"s05_station": ["old_postman"],
			"s07_military_town": ["military_order", "military_companion"],
		},
		"shan": {},
		"expect_ending": "ending_canonical",
		"expect_fallback": true,
	},
	"truth_verified": {
		"prefer": {
			"s05_station": "询问送信路线",
			"s06_ferry": "保存证言",
			"s09_recall_chain": "先帮助迁徙者并保存证言",
			"s11_outcome_router": "查看见证者真相线",
			"s12_leave_or_continue": "继续游戏，见证并帮助辛弃疾",
		},
		"investigate": {
			"s05_station": ["station_letter", "old_postman"],
			"s06_ferry": ["migrant_witness"],
			"s07_military_town": ["military_order"],
		},
		"shan": {
			"s06_ferry": ["testimony_meaning"],
		},
		"expect_ending": "ending_truth",
	},
	"canonical_missed": {
		"prefer": {
			"s05_station": "记下老驿卒的证言",
			"s06_ferry": "只记录路线",
			"s07_military_town": "查路线图",
			"s09_recall_chain": "先帮助迁徙者并保存证言",
			"s11_outcome_router": "查看历史轨迹",
			"s12_leave_or_continue": "直接进入下一章",
		},
		"investigate": {},
		"shan": {},
		"expect_ending": "ending_canonical",
		"expect_missed_min": 2,
	},
	"exhausted_questions": {
		"prefer": {
			"s05_station": "记下老驿卒的证言",
			"s06_ferry": "只记录路线",
			"s07_military_town": "查路线图",
			"s09_recall_chain": "先帮助迁徙者并保存证言",
			"s11_outcome_router": "查看历史轨迹",
			"s12_leave_or_continue": "直接进入下一章",
		},
		"investigate": {},
		"shan": {
			"s05_station": ["route_explain", "letter_chain"],
			"s06_ferry": ["testimony_meaning"],
			"s07_military_town": ["recall_chain"],
		},
		"expect_ending": "ending_canonical",
		"expect_questions_left": 0,
		"expect_shan_status": "exhausted",
	},
}

func _initialize() -> void:
	var failures := 0
	for route_name in routes.keys():
		if not await _run_route(route_name, routes[route_name]):
			failures += 1
	if failures == 0:
		print("SMOKE OK: %d/%d routes reached their expected endings" % [routes.size(), routes.size()])
	else:
		print("SMOKE FAILED: %d route(s) failed" % failures)
	quit(failures)

func _run_route(route_name: String, route: Dictionary) -> bool:
	var main = (load(MAIN_SCENE) as PackedScene).instantiate()
	root.add_child(main)
	await process_frame
	var trail: Array = [main.current_scene_id]
	var shan_statuses: Array = []
	var used_fallback := false
	var processed_scenes: Array = []
	var steps := 0
	var finished := false
	while steps < MAX_STEPS:
		steps += 1
		var scene_id: String = main.current_scene_id
		if scene_id not in processed_scenes:
			processed_scenes.append(scene_id)
			for object_id in route.get("investigate", {}).get(scene_id, []):
				main.investigate(str(object_id))
			for prompt_id in route.get("shan", {}).get(scene_id, []):
				shan_statuses.append(main.ask_shan(str(prompt_id)))
		var scene: Dictionary = main.scenes_by_id.get(scene_id, {})
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
			if choice == null and not main.fallback_choice.is_empty():
				used_fallback = true
				choice = main.fallback_choice
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
	var problems := PackedStringArray()
	if route.get("expect_fallback", false) and not used_fallback:
		ok = false
		problems.append("expected the ordinary-closure fallback to trigger")
	if route.has("expect_missed_min") and main.runtime.get("missed_critical_clues", []).size() < int(route["expect_missed_min"]):
		ok = false
		problems.append("expected >= %d missed clues, got %d" % [int(route["expect_missed_min"]), main.runtime.get("missed_critical_clues", []).size()])
	if route.has("expect_questions_left") and int(main.runtime.get("shan_questions_left", -1)) != int(route["expect_questions_left"]):
		ok = false
		problems.append("expected questions_left == %d, got %d" % [int(route["expect_questions_left"]), int(main.runtime.get("shan_questions_left", -1))])
	if route.has("expect_shan_status") and str(route["expect_shan_status"]) not in shan_statuses:
		ok = false
		problems.append("expected a '%s' shan answer, statuses=%s" % [str(route["expect_shan_status"]), str(shan_statuses)])
	print("ROUTE %s: %s | ending=%s expected=%s | steps=%d%s" % [route_name, "OK" if ok else "FAILED", ending, expected, steps, " | fallback" if used_fallback else ""])
	print("  trail: %s" % " -> ".join(PackedStringArray(trail)))
	print("  state: clues=%d verified=%d fragments=%d missed=%d inquiries=%d trust=%d shan_left=%d branch=%s" % [
		main.runtime.get("clues_found", []).size(),
		main.runtime.get("verified_clues", []).size(),
		main.runtime.get("clue_fragments", []).size(),
		main.runtime.get("missed_critical_clues", []).size(),
		int(main.runtime.get("inquiry_count", 0)),
		int(main.runtime.get("trust_military", 0)),
		int(main.runtime.get("shan_questions_left", 0)),
		str(main.runtime.get("branch", ""))])
	if not shan_statuses.is_empty():
		print("  shan: %s" % str(shan_statuses))
	for problem in problems:
		print("  PROBLEM: %s" % problem)
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

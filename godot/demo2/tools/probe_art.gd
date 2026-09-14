extends SceneTree
# Headless probe: does each scene show its background, and does each speaker
# switch the center-stage portrait?
func _initialize() -> void:
	var main = (load("res://main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	await process_frame
	var visited := {}
	var steps := 0
	while steps < 60:
		steps += 1
		var sid: String = main.current_scene_id
		var scene: Dictionary = main.scenes_by_id.get(sid, {})
		var beats: Array = scene.get("beats", [])
		if main.current_beat_index >= beats.size():
			break
		var beat: Dictionary = beats[main.current_beat_index]
		var speaker := str(beat.get("speaker", "旁白"))
		var key := sid + "|" + speaker
		if key not in visited:
			visited[key] = true
			var bg_ok: bool = main.bg_texture.visible and main.bg_texture.texture != null
			var portrait: String = "hidden"
			if main.char_portrait.visible and main.char_portrait.texture != null:
				portrait = "%dx%d" % [main.char_portrait.texture.get_width(), main.char_portrait.texture.get_height()]
			var shan: String = "on" if (main.shan_sprite != null and main.shan_sprite.visible) else "off"
			print("%-22s %-8s bg=%s portrait=%s liushan=%s" % [sid, speaker, "ok" if bg_ok else "MISSING", portrait, shan])
		var choices: Array = beat.get("choices", [])
		if choices.is_empty():
			main._advance()
		else:
			var picked = null
			for c in choices:
				if main._choice_available(c):
					picked = c
					break
			if picked == null: break
			main._choose(picked)
	quit(0)

extends SceneTree
# Headless probe: verify per-scene BGM/ambience resolve and that SFX cues load.
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
		if main.current_beat_index >= beats.size(): break
		if sid not in visited:
			visited[sid] = true
			var bgm := "none"
			if main.bgm_player.stream != null:
				bgm = str(main.bgm_player.stream.resource_path).get_file() if main.bgm_player.stream.resource_path != "" else "loaded"
			var amb := "none"
			if main.ambience_player.stream != null:
				amb = str(main.ambience_player.stream.resource_path).get_file() if main.ambience_player.stream.resource_path != "" else "loaded"
			print("%-22s bgm=%-32s amb=%s" % [sid, bgm, amb])
		var beat: Dictionary = beats[main.current_beat_index]
		var choices: Array = beat.get("choices", [])
		if choices.is_empty():
			main._advance()
		else:
			var picked = null
			for c in choices:
				if main._choice_available(c): picked = c; break
			if picked == null: break
			main._choose(picked)
	# SFX cue coverage
	var sfx_map: Dictionary = main.manifest.get("assets", {}).get("audio_sfx_map", {})
	var missing := []
	for cue in sfx_map.keys():
		main.play_sfx(str(cue))
		var p: AudioStreamPlayer = main.sfx_players[0]
		if p.stream == null: missing.append(str(cue))
	print("SFX cues loaded: ", sfx_map.size() - missing.size(), "/", sfx_map.size(), (" missing=" + str(missing)) if missing.size() else "")
	quit(0)

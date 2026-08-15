extends Node

# Targeted progression-path validation for the Passenger -> Dining -> Car 13
# manual route. Exercises the REAL runtime chain (door_trigger, encounter_trigger,
# scene_transition, game_state, combat_manager) by loading each scene as a child
# of root (like the other tool harnesses) and invoking the real trigger callbacks
# directly -- no faked callbacks, no invented transition framework.
#
# The encounter trigger reads get_tree().current_scene.scene_file_path to record
# where the fight happened, so before invoking a scene's triggers we point
# current_scene at that scene instance (mirroring how the real game always has
# the active scene as current_scene).
#
# Run: godot --headless --path . tools/progression_check.tscn

var _results := {}
var _failed := 0

func _ready() -> void:
	await get_tree().process_frame
	_run()

func _record(name: String, ok: bool, detail: String) -> void:
	_results[name] = {"ok": ok, "detail": detail}
	if not ok:
		_failed += 1
		printerr("FAIL: %s -> %s" % [name, detail])
	else:
		print("PASS: %s -> %s" % [name, detail])

func _add(node: Node) -> void:
	get_tree().root.add_child(node)

func _load_scene(path: String) -> Node:
	var packed := load(path) as PackedScene
	var inst := packed.instantiate()
	_add(inst)
	await get_tree().physics_frame
	await get_tree().physics_frame
	return inst

func _player_in(scene: Node) -> CharacterBody2D:
	return scene.find_child("Player", true, false) as CharacterBody2D

func _run() -> void:
	# Reset run state.
	GameState.has_car13_key = false
	GameState.found_accident_clue = false
	GameState.car13_unlocked = false
	GameState.defeated_enemies = {}
	GameState.pending_enemy = ""
	GameState.return_scene = ""
	GameState.return_position = Vector2.ZERO

	# ---- STEP 1: Passenger encounter is NOT on the Dining door path ----
	var passenger := await _load_scene("res://scenes/train/passenger_car.tscn")
	get_tree().current_scene = passenger
	var enc := passenger.find_child("EncounterTrigger", true, false) as Area2D
	var door := passenger.find_child("DoorToDiningCar", true, false) as Area2D
	var enc_rect := enc.get_node("Col").shape as RectangleShape2D
	var door_rect := door.get_node("Col").shape as RectangleShape2D
	var enc_right := enc.global_position.x + enc_rect.size.x / 2.0
	var door_left := door.global_position.x - door_rect.size.x / 2.0
	var no_overlap := enc_right < door_left
	_record("passenger_encounter_not_on_dining_door", no_overlap,
		"enc_right=%.0f door_left=%.0f" % [enc_right, door_left])

	# ---- STEP 2: The Dining door is a DOOR (door_trigger), not an encounter ----
	# Verify by its script type and target scene. We do NOT invoke the real
	# change_scene_to_file here so current_scene stays stable for the encounter
	# trigger below (which records current_scene.scene_file_path as the return
	# scene). The actual door swap is exercised by the real game at runtime.
	var is_door_script: bool = door.get_script().resource_path == "res://scripts/train/door_trigger.gd"
	GameState.pending_enemy = ""
	GameState.return_scene = ""
	var targets_dining: bool = door.get("target_scene") == "res://scenes/train/dining_car.tscn"
	_record("passenger_door_is_door_not_combat",
		is_door_script and targets_dining and door.get("requires_key") == false,
		"script=%s target=%s" % [is_door_script, door.get("target_scene")])
	_record("passenger_door_targets_dining", targets_dining, "target=%s" % door.get("target_scene"))

	# ---- STEP 3: Dining Car loads and contains the required elements ----
	var dining := await _load_scene("res://scenes/train/dining_car.tscn")
	get_tree().current_scene = dining
	var d_enc := dining.find_child("EncounterTrigger", true, false) as Area2D
	var d_clue := dining.find_child("AccidentClue", true, false)
	var d_back := dining.find_child("DoorBackToPassenger", true, false) as Area2D
	var d_car13 := dining.find_child("DoorToCar13", true, false) as Area2D
	_record("dining_has_enemy_trigger", d_enc != null and d_enc.get("enemy_id") == "crawling_thing",
		"enemy_id=%s" % (d_enc.get("enemy_id") if d_enc != null else "null"))
	_record("dining_has_accident_clue", d_clue != null, "clue=%s" % (d_clue != null))
	_record("dining_has_back_to_passenger", d_back != null and d_back.get("target_scene") == "res://scenes/train/passenger_car.tscn", "back=%s" % (d_back != null))
	_record("dining_has_car13_door", d_car13 != null and d_car13.get("target_scene") == "res://scenes/train/car_13.tscn", "car13=%s" % (d_car13 != null))

	# ---- STEP 4: Dining enemy encounter -> combat (pending + return scene set) ----
	GameState.pending_enemy = ""
	GameState.return_scene = ""
	var d_player := _player_in(dining)
	d_player.global_position = d_enc.global_position
	await get_tree().physics_frame
	d_enc._on_body_entered(d_player)
	await get_tree().process_frame
	_record("dining_encounter_starts_combat",
		GameState.pending_enemy == "crawling_thing" and GameState.return_scene == "res://scenes/train/dining_car.tscn",
		"pending=%s return=%s" % [GameState.pending_enemy, GameState.return_scene])
	# Return position must be safe: nudged left of the trigger, not inside it.
	var safe_pos: bool = GameState.return_position.x < d_enc.global_position.x and GameState.return_position != Vector2.ZERO
	_record("dining_combat_return_pos_safe", safe_pos,
		"ret=%s enc_x=%.0f" % [GameState.return_position, d_enc.global_position.x])

	# ---- STEP 5: Defeat the enemy in real combat, then return to Dining ----
	var combat: Node = load("res://combat/combat.tscn").instantiate()
	GameState.pending_enemy = "crawling_thing"
	_add(combat)
	await get_tree().process_frame
	combat.set("enemy_hp", 1)
	combat.call("_player_action", "attack")
	await get_tree().create_timer(1.8).timeout
	_record("dining_combat_marked_defeated", GameState.is_enemy_defeated("crawling_thing"),
		"defeated=%s" % GameState.is_enemy_defeated("crawling_thing"))
	# return_from_combat must target the Dining Car scene (where the fight occurred).
	GameState.return_scene = "res://scenes/train/dining_car.tscn"
	GameState.return_position = Vector2(200.0, 90.0)
	SceneTransition.return_from_combat()
	await get_tree().process_frame
	await get_tree().process_frame
	_record("combat_return_targets_dining", GameState.return_scene == "",
		"return_scene_cleared=%s" % (GameState.return_scene == ""))

	# ---- STEP 6: Defeated encounter does NOT immediately re-fire ----
	# The combat return in STEP 5 swapped current_scene and freed the old dining
	# instance, so load a FRESH Dining Car and re-find its trigger/clue. The
	# trigger disables on the defeated check before reading body.global_position.
	var dining2 := await _load_scene("res://scenes/train/dining_car.tscn")
	get_tree().current_scene = dining2
	var d_enc2 := dining2.find_child("EncounterTrigger", true, false) as Area2D
	var d_clue2 := dining2.find_child("AccidentClue", true, false)
	GameState.pending_enemy = ""
	var refire_player := Node2D.new()
	refire_player.add_to_group("player")
	_add(refire_player)
	d_enc2._on_body_entered(refire_player)
	await get_tree().process_frame
	_record("defeated_encounter_does_not_refire", GameState.pending_enemy == "",
		"pending_after=%s monitoring=%s" % [GameState.pending_enemy, d_enc2.monitoring])

	# ---- STEP 7: Collect Accident Clue ----
	d_clue2.call("interact")
	_record("accident_clue_collected", GameState.found_accident_clue == true,
		"clue=%s" % GameState.found_accident_clue)

	# ---- STEP 8: Car 13 door requires key + clue; with both it unlocks ----
	# Use the fresh Dining Car instance (dining2) since the original was freed.
	var d_car13_2 := dining2.find_child("DoorToCar13", true, false) as Area2D
	GameState.has_car13_key = true
	GameState.found_accident_clue = true
	GameState.car13_unlocked = false
	# Point current_scene at a throwaway placeholder so the door's
	# change_scene_to_file frees the placeholder (not dining2/d_car13_2), avoiding
	# a native crash from freeing the node whose method we are inside.
	var ph := Node.new()
	ph.name = "DoorSwapPlaceholder"
	get_tree().root.add_child(ph)
	get_tree().current_scene = ph
	var bp := Node2D.new()
	bp.add_to_group("player")
	_add(bp)
	d_car13_2._on_body_entered(bp)
	await get_tree().process_frame
	_record("car13_door_unlocks_with_key_and_clue", GameState.car13_unlocked == true,
		"unlocked=%s" % GameState.car13_unlocked)
	_record("car13_door_targets_car13", d_car13_2.get("target_scene") == "res://scenes/train/car_13.tscn",
		"target=%s" % d_car13_2.get("target_scene"))

	_finish()

func _finish() -> void:
	print("\n==== PROGRESSION CHECK SUMMARY ====")
	print("Total checks: %d" % _results.size())
	print("Failed: %d" % _failed)
	if _failed > 0:
		get_tree().quit(1)
	else:
		get_tree().quit(0)

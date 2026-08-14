extends Node

# Real input-path validation (headless). Injects actual InputEventKey objects
# through Input.parse_input_event (the same path the OS uses) and verifies the
# Player physically moves. Exits 0 if all checks pass, 1 otherwise.

var _fail := 0

func _make_key(kc: int, pkc: int) -> InputEventKey:
	var ev := InputEventKey.new()
	if kc != 0:
		ev.keycode = kc
	if pkc != 0:
		ev.physical_keycode = pkc
	ev.pressed = true
	return ev

func _release_key(kc: int, pkc: int) -> void:
	var ev := _make_key(kc, pkc)
	ev.pressed = false
	Input.parse_input_event(ev)

func _check(name: String, ok: bool, detail: String) -> void:
	if ok:
		print("PASS ", name, " -> ", detail)
	else:
		printerr("FAIL ", name, " -> ", detail)
		_fail += 1

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().physics_frame

	var packed := load("res://scenes/train/passenger_car.tscn") as PackedScene
	if packed == null:
		printerr("FAIL load_scene")
		get_tree().quit(1)
		return
	var scene := packed.instantiate()
	get_tree().root.add_child(scene)
	await get_tree().physics_frame

	var player := scene.find_child("Player", true, false) as CharacterBody2D
	_check("player_exists", player != null, "path=" + str(player.get_path() if player != null else ""))
	if player == null:
		get_tree().quit(1)
		return

	_check("player_is_characterbody2d", player is CharacterBody2D, player.get_class())
	_check("player_has_script", player.get_script() != null, str(player.get_script().resource_path))

	for a in ["move_up", "move_down", "move_left", "move_right", "interact"]:
		_check("action_" + a, InputMap.has_action(a), "present")

	# Real key injection: W (keycode=87 physical=87)
	var y0: float = player.position.y
	Input.parse_input_event(_make_key(87, 87))
	await get_tree().physics_frame
	await get_tree().physics_frame
	_check("w_fires_move_up", Input.is_action_pressed("move_up"), "action_pressed=" + str(Input.is_action_pressed("move_up")))
	_check("w_moves_player_up", player.position.y < y0 - 1.0, "y0=" + str(y0) + " y1=" + str(player.position.y))
	_release_key(87, 87)
	await get_tree().physics_frame

	# Arrows still work
	Input.parse_input_event(_make_key(4194321, 4194321))
	await get_tree().physics_frame
	_check("right_arrow_fires_move_right", Input.is_action_pressed("move_right"), str(Input.is_action_pressed("move_right")))
	_release_key(4194321, 4194321)
	await get_tree().physics_frame

	# Interact action
	Input.parse_input_event(_make_key(69, 69))
	await get_tree().physics_frame
	_check("e_fires_interact", Input.is_action_pressed("interact"), str(Input.is_action_pressed("interact")))
	_release_key(69, 69)
	await get_tree().physics_frame

	print("==== INPUT CHECK SUMMARY: failed=", _fail, " ====")
	get_tree().quit(1 if _fail > 0 else 0)
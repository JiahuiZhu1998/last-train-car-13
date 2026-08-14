extends Node

var _enc_pending := ""

func _ready() -> void:
	await get_tree().process_frame
	var placeholder := Node.new()
	placeholder.name = "ValidatorPlaceholder"
	get_tree().root.add_child(placeholder)
	get_tree().current_scene = placeholder
	await get_tree().process_frame

	GameState.has_car13_key = false
	GameState.pending_enemy = ""

	var packed := load("res://scenes/train/passenger_car.tscn") as PackedScene
	var scene := packed.instantiate()
	get_tree().root.add_child(scene)
	await get_tree().physics_frame

	var player := scene.find_child("Player", true, false) as CharacterBody2D
	var key := scene.find_child("Car13Key", true, false)
	var encounter := scene.find_child("EncounterTrigger", true, false)

	# KEY real overlap
	player.position = key.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	var key_ok := GameState.has_car13_key
	print("COLLISION KEY overlap collected = ", key_ok)

	# ENCOUNTER real overlap
	encounter.body_entered.connect(_on_encounter_body_entered)
	GameState.pending_enemy = ""
	player.position = encounter.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	var enc_ok := _enc_pending == "shadow_passenger"
	print("COLLISION ENCOUNTER overlap fired = ", enc_ok, " pending=", _enc_pending)

	var ok := key_ok and enc_ok
	print("COLLISION VALIDATION ", "PASS" if ok else "FAIL")
	get_tree().quit(0 if ok else 1)

func _on_encounter_body_entered(body: Node) -> void:
	_enc_pending = GameState.pending_enemy
	print("COLLISION ENCOUNTER body_entered for: ", body.name, " is_player=", body.is_in_group("player"))
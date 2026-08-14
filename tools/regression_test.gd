extends Node

# Headless regression harness for Last Train: Car 13 (Day 2 scope).
# Run with:  godot --headless --path . tools/regression_test.tscn
# Autoloads (GameState, SceneTransition) are available because this runs as a
# normal game scene. The harness reparents current_scene to a placeholder so
# scene transitions triggered by game code (door entry, combat return) never
# free the harness mid-run.

var _results := {}
var _failed := 0

func _ready() -> void:
	await get_tree().process_frame
	var placeholder := Node.new()
	placeholder.name = "RegressionPlaceholder"
	get_tree().root.add_child(placeholder)
	get_tree().current_scene = placeholder
	await get_tree().process_frame
	_run_checks()

func _run_checks() -> void:
	_check_all_scenes_instantiate()
	_check_dialogue_balloon_toggle()
	_check_door_gate_without_key()
	_check_door_gate_with_key_only()
	_check_door_gate_with_both()
	_check_key_pickup_flow()
	_check_clue_pickup_flow()
	await _check_combat()
	_finish()

func _add(node: Node) -> void:
	get_tree().root.add_child(node)

func _check_all_scenes_instantiate() -> void:
	var scenes := [
		"res://scenes/train/passenger_car.tscn",
		"res://scenes/train/dining_car.tscn",
		"res://scenes/train/car_13.tscn",
		"res://combat/combat.tscn",
		"res://scenes/ending/engine_cabin.tscn",
	]
	for scene in scenes:
		var packed: PackedScene = load(scene)
		if packed == null:
			_record("instantiate_%s" % scene, false, "load returned null")
			continue
		var inst: Node = packed.instantiate()
		_add(inst)
		_record("instantiate_%s" % scene, inst != null, "ok")
		inst.queue_free()

func _check_dialogue_balloon_toggle() -> void:
	var npc_script: GDScript = load("res://scripts/characters/npc.gd")
	var npc: Node2D = Node2D.new()
	npc.set_script(npc_script)
	var balloon: CanvasLayer = CanvasLayer.new()
	balloon.name = "DialogueBalloon"
	balloon.visible = false
	var label: Label = Label.new()
	label.name = "Label"
	balloon.add_child(label)
	npc.add_child(balloon)
	_add(npc)
	npc.interact()
	var balloon_node: Node = npc.find_child("DialogueBalloon", true, false)
	var opened: bool = balloon_node.visible
	npc.interact()
	var closed: bool = not balloon_node.visible
	_record("dialogue_opens_and_closes", opened and closed,
		"opened=%s closed=%s" % [opened, closed])
	npc.queue_free()

func _make_door(target: String, requires_key: bool, requires_clue: bool, unlocks_car13: bool) -> Area2D:
	var door_script: GDScript = load("res://scripts/train/door_trigger.gd")
	var door: Area2D = Area2D.new()
	door.set_script(door_script)
	door.set("target_scene", target)
	door.set("requires_key", requires_key)
	door.set("requires_clue", requires_clue)
	door.set("unlocks_car13", unlocks_car13)
	var label: Label = Label.new()
	label.name = "DoorLabel"
	door.add_child(label)
	_add(door)
	return door

func _player_body() -> Node2D:
	var p: Node2D = Node2D.new()
	p.add_to_group("player")
	_add(p)
	return p

func _check_door_gate_without_key() -> void:
	GameState.has_car13_key = false
	GameState.found_accident_clue = false
	GameState.car13_unlocked = false
	var door: Area2D = _make_door("res://scenes/train/car_13.tscn", true, true, true)
	var body: Node2D = _player_body()
	door._on_body_entered(body)
	var label_node: Label = door.find_child("DoorLabel", true, false) as Label
	var ok: bool = label_node.text == "The door is locked."
	_record("door_blocked_without_key", ok, "label=%s" % label_node.text)
	door.queue_free()
	body.queue_free()

func _check_door_gate_with_key_only() -> void:
	GameState.has_car13_key = true
	GameState.found_accident_clue = false
	GameState.car13_unlocked = false
	var door: Area2D = _make_door("res://scenes/train/car_13.tscn", true, true, true)
	var body: Node2D = _player_body()
	door._on_body_entered(body)
	var label_node: Label = door.find_child("DoorLabel", true, false) as Label
	var ok: bool = label_node.text == "Something tells me I should learn what happened before entering."
	_record("door_blocked_with_key_only", ok, "label=%s" % label_node.text)
	door.queue_free()
	body.queue_free()

func _check_door_gate_with_both() -> void:
	GameState.has_car13_key = true
	GameState.found_accident_clue = true
	GameState.car13_unlocked = false
	var door: Area2D = _make_door("res://scenes/train/car_13.tscn", true, true, true)
	var body: Node2D = _player_body()
	door._on_body_entered(body)
	var ok: bool = GameState.car13_unlocked == true
	_record("door_unlocks_with_key_and_clue", ok, "car13_unlocked=%s" % GameState.car13_unlocked)
	door.queue_free()
	body.queue_free()

func _make_pickup(script_path: String, visual_name: String) -> Node:
	var s: GDScript = load(script_path)
	var node: Node2D = Node2D.new()
	node.set_script(s)
	var area: Area2D = Area2D.new()
	area.name = "PickupArea"
	node.add_child(area)
	var visual: ColorRect = ColorRect.new()
	visual.name = visual_name
	node.add_child(visual)
	var feedback: Label = Label.new()
	feedback.name = "FeedbackLabel"
	node.add_child(feedback)
	_add(node)
	return node

func _check_key_pickup_flow() -> void:
	if not ResourceLoader.exists("res://scripts/props/car13_key.gd"):
		_record("key_pickup_flow", false, "car13_key.gd missing")
		return
	GameState.has_car13_key = false
	var k: Node = _make_pickup("res://scripts/props/car13_key.gd", "KeyVisual")
	var before: bool = GameState.has_car13_key
	k.call("interact")
	var after: bool = GameState.has_car13_key
	var inactive: bool = not bool(k.get("active"))
	k.call("interact")
	var still: bool = GameState.has_car13_key
	_record("key_pickup_flow", before == false and after == true and inactive and still == true,
		"before=%s after=%s inactive=%s still=%s" % [before, after, inactive, still])
	k.queue_free()

func _check_clue_pickup_flow() -> void:
	if not ResourceLoader.exists("res://scripts/props/accident_clue.gd"):
		_record("clue_pickup_flow", false, "accident_clue.gd missing")
		return
	GameState.found_accident_clue = false
	var c: Node = _make_pickup("res://scripts/props/accident_clue.gd", "ClueVisual")
	var before: bool = GameState.found_accident_clue
	c.call("interact")
	var after: bool = GameState.found_accident_clue
	var inactive: bool = not bool(c.get("active"))
	c.call("interact")
	var still: bool = GameState.found_accident_clue
	_record("clue_pickup_flow", before == false and after == true and inactive and still == true,
		"before=%s after=%s inactive=%s still=%s" % [before, after, inactive, still])
	c.queue_free()

func _check_combat() -> void:
	var scene: PackedScene = load("res://combat/combat.tscn")
	var inst: Node = scene.instantiate()
	GameState.pending_enemy = "shadow_passenger"
	_add(inst)
	await get_tree().process_frame
	var enemy_hp: int = int(inst.get("enemy_hp"))
	var enemy_name: String = String(inst.get("enemy_name"))
	_record("combat_initializes", enemy_hp > 0 and enemy_name != "",
		"enemy_hp=%s name=%s" % [enemy_hp, enemy_name])
	var before: int = int(inst.get("enemy_hp"))
	inst.call("_player_action", "attack")
	await get_tree().create_timer(1.0).timeout
	var after: int = int(inst.get("enemy_hp"))
	_record("combat_attack_reduces_hp", after < before, "before=%s after=%s" % [before, after])
	inst.set("enemy_hp", 1)
	GameState.return_scene = "res://scenes/train/passenger_car.tscn"
	inst.call("_player_action", "attack")
	await get_tree().create_timer(1.7).timeout
	var combat_active: bool = bool(inst.get("_combat_active"))
	_record("combat_victory_ends", combat_active == false, "combat_active=%s" % combat_active)
	inst.queue_free()

func _record(name: String, ok: bool, detail: String) -> void:
	_results[name] = {"ok": ok, "detail": detail}
	if not ok:
		_failed += 1
		printerr("FAIL: %s -> %s" % [name, detail])
	else:
		print("PASS: %s -> %s" % [name, detail])

func _finish() -> void:
	var total: int = _results.size()
	var failed: int = _failed
	print("\n==== REGRESSION SUMMARY ====")
	print("Total checks: %d" % total)
	print("Failed: %d" % failed)
	if failed > 0:
		get_tree().quit(1)
	else:
		get_tree().quit(0)
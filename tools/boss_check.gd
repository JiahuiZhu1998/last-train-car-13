extends Node

var _results := {}
var _failed := 0

func _ready() -> void:
    await get_tree().process_frame
    var placeholder := Node.new()
    placeholder.name = "BossCheckPlaceholder"
    get_tree().root.add_child(placeholder)
    get_tree().current_scene = placeholder
    await get_tree().process_frame
    await _run_checks()

func _add(node: Node) -> void:
    get_tree().root.add_child(node)

func _run_checks() -> void:
    GameState.conductor_defeated = false
    GameState.found_accident_clue = false
    await _check_conductor_stats()
    await _check_inspect_text()
    GameState.conductor_defeated = false
    await _check_conductor_defeat()
    GameState.conductor_defeated = false
    _check_engine_door_locked()
    await _check_engine_cabin_instantiates()
    _finish()

func _check_conductor_stats() -> void:
    var scene: PackedScene = load("res://combat/combat.tscn")
    var inst: Node = scene.instantiate()
    GameState.pending_enemy = "the_conductor"
    _add(inst)
    await get_tree().process_frame
    var ok := int(inst.get("enemy_hp")) == 28 and int(inst.get("enemy_attack")) == 6 and int(inst.get("enemy_defense")) == 3 and String(inst.get("enemy_name")) == "The Conductor"
    _record("conductor_stats", ok, "hp=%s atk=%s def=%s name=%s" % [inst.get("enemy_hp"), inst.get("enemy_attack"), inst.get("enemy_defense"), inst.get("enemy_name")])
    inst.queue_free()

func _check_inspect_text() -> void:
    var scene: PackedScene = load("res://combat/combat.tscn")
    var inst: Node = scene.instantiate()
    GameState.pending_enemy = "the_conductor"
    _add(inst)
    await get_tree().process_frame
    var t: String = inst.call("_get_inspect_text")
    var ok := t.contains("uniform is burned") and t.contains("Night Express 13")
    _record("conductor_inspect_text", ok, "text=%s" % t)
    inst.queue_free()

func _check_conductor_defeat() -> void:
    GameState.conductor_defeated = false
    var scene: PackedScene = load("res://combat/combat.tscn")
    var inst: Node = scene.instantiate()
    GameState.pending_enemy = "the_conductor"
    _add(inst)
    await get_tree().process_frame
    inst.set("enemy_hp", 1)
    GameState.return_scene = "res://scenes/train/car_13.tscn"
    inst.call("_player_action", "attack")
    await get_tree().create_timer(1.8).timeout
    var ok := GameState.conductor_defeated == true
    _record("conductor_defeat_sets_flag", ok, "conductor_defeated=%s" % GameState.conductor_defeated)
    inst.queue_free()

func _check_engine_door_locked() -> void:
    GameState.conductor_defeated = false
    var door_script: GDScript = load("res://scripts/train/door_trigger.gd")
    var door: Area2D = Area2D.new()
    door.set_script(door_script)
    door.set("target_scene", "res://scenes/ending/engine_cabin.tscn")
    door.set("requires_conductor_defeated", true)
    var label: Label = Label.new()
    label.name = "DoorLabel"
    door.add_child(label)
    _add(door)
    var body: Node2D = Node2D.new()
    body.add_to_group("player")
    _add(body)
    door._on_body_entered(body)
    var lbl: Label = door.find_child("DoorLabel", true, false) as Label
    var ok := lbl.text == "The engine cabin door is locked."
    _record("engine_door_locked_without_defeat", ok, "label=%s req=%s state=%s" % [lbl.text, door.get("requires_conductor_defeated"), GameState.conductor_defeated])
    door.queue_free()
    body.queue_free()

func _check_engine_cabin_instantiates() -> void:
    var packed: PackedScene = load("res://scenes/ending/engine_cabin.tscn")
    var ok := packed != null
    if ok:
        var inst: Node = packed.instantiate()
        _add(inst)
        await get_tree().process_frame
        ok = GameState.ending_unlocked == true
        _record("engine_cabin_sets_ending", ok, "ending_unlocked=%s" % GameState.ending_unlocked)
        inst.queue_free()
    else:
        _record("engine_cabin_sets_ending", false, "load null")

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
    print("\n==== BOSS CHECK SUMMARY ====")
    print("Total checks: %d" % total)
    print("Failed: %d" % failed)
    if failed > 0:
        get_tree().quit(1)
    else:
        get_tree().quit(0)

extends Node

# Handles scene transitions with a brief fade.
# Usage: SceneTransition.go_to("res://scenes/combat/combat.tscn")

signal transition_finished

var _current_scene: String = ""

func go_to(path: String) -> void:
	_current_scene = path
	get_tree().change_scene_to_file(path)

func go_to_combat(enemy_id: String, return_to: String, return_pos: Vector2) -> void:
	GameState.pending_enemy = enemy_id
	GameState.return_scene = return_to
	GameState.return_position = return_pos
	go_to("res://combat/combat.tscn")

func return_from_combat() -> void:
	var target = GameState.return_scene
	var pos = GameState.return_position
	GameState.pending_enemy = ""
	GameState.return_scene = ""
	GameState.return_position = Vector2.ZERO
	# Defer the scene change so any pending combat cleanup (queue_free, etc.)
	# finishes before the new scene is instantiated.
	call_deferred("_do_return", target, pos)

func _do_return(target: String, pos: Vector2) -> void:
	get_tree().change_scene_to_file(target)
	# After the scene swap, restore the player's position so combat returns the
	# player to where the encounter actually occurred (not the scene's default
	# spawn point). We wait one frame for the new scene tree to be ready.
	if pos != Vector2.ZERO:
		await get_tree().process_frame
		var player := get_tree().current_scene
		if player == null:
			return
		var p := player.find_child("Player", true, false) as CharacterBody2D
		if p != null:
			p.global_position = pos

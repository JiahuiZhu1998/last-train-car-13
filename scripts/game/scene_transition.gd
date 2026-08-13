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
	GameState.pending_enemy = ""
	GameState.return_scene = ""
	go_to(target)

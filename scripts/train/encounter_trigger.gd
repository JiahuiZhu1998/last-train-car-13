extends Area2D

# Triggers a combat encounter when the player enters.
# collision_mask must include the player collision layer (1).

@export var enemy_id: String = "shadow_passenger"
@export var one_shot: bool = true

var _triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	if not body.is_in_group("player"):
		return
	if one_shot:
		_triggered = true

	var return_scene := get_tree().current_scene.scene_file_path
	var return_pos: Vector2 = body.global_position
	SceneTransition.go_to_combat(enemy_id, return_scene, return_pos)
extends Area2D

# Triggers a combat encounter when the player enters.
# collision_mask must include the player collision layer (1).

@export var enemy_id: String = "shadow_passenger"
@export var one_shot: bool = true

# Offset (in the scene's local space) applied to the player's position when
# returning from combat, so the player lands a safe distance away from this
# trigger rather than directly inside it. Points back toward where the player
# came from (left, toward the room interior).
@export var return_offset: Vector2 = Vector2(-40.0, 0.0)

var _triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# If this encounter was already resolved this run, disable it so it never
	# re-fires and never traps the player in a combat-return loop.
	if GameState.is_enemy_defeated(enemy_id):
		_disable()

func _disable() -> void:
	monitoring = false
	monitorable = false
	if has_node("Col"):
		$Col.disabled = true

func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	if not body.is_in_group("player"):
		return
	if GameState.is_enemy_defeated(enemy_id):
		_disable()
		return
	if one_shot:
		_triggered = true

	var return_scene := get_tree().current_scene.scene_file_path
	# Return the player to where the encounter occurred, nudged clear of the
	# trigger so they don't immediately re-enter it on the next physics frame.
	var return_pos: Vector2 = body.global_position + return_offset
	SceneTransition.go_to_combat(enemy_id, return_scene, return_pos)
extends CharacterBody2D

const SPEED = 80.0

@onready var interaction_area: Area2D = $InteractionArea
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("player")

func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		# Flip sprite based on horizontal movement
		if direction.x != 0:
			sprite.flip_h = direction.x < 0

	velocity = direction * SPEED
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact()

func _try_interact() -> void:
	# Check areas first (NPCs expose a HitArea child on collision layer 4)
	for area in interaction_area.get_overlapping_areas():
		var owner_node := area.get_parent()
		if owner_node != null and owner_node.has_method("interact"):
			owner_node.interact()
			return

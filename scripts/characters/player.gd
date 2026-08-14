extends CharacterBody2D

const SPEED = 80.0

# Temporary gray-box visual: PLAYER is a bright cyan rectangle.
func _make_square(color: Color) -> ImageTexture:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)

@onready var interaction_area: Area2D = $InteractionArea
@onready var sprite: Sprite2D = $Sprite2D
var _logged_move := false

func _ready() -> void:
	add_to_group("player")
	sprite.texture = _make_square(Color(0.2, 0.85, 1.0, 1.0))
	print("PLAYER READY")
	print("PLAYER path=", get_path())

func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		if direction.x != 0:
			sprite.flip_h = direction.x < 0
		if not _logged_move:
			print("MOVE INPUT active vector=", direction)
			_logged_move = true
	else:
		_logged_move = false
	velocity = direction * SPEED
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		print("INTERACT PRESSED")
		_try_interact()

func _try_interact() -> void:
	# Check areas first (NPCs expose a HitArea child on collision layer 4)
	for area in interaction_area.get_overlapping_areas():
		var owner_node := area.get_parent()
		if owner_node != null and owner_node.has_method("interact"):
			owner_node.interact()
			return
extends Area2D

# Door/transition trigger — sends the player to another scene.

@export var target_scene: String = "res://scenes/train/dining_car.tscn"
@export var requires_key: bool = false

@onready var label: Label = $Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if requires_key:
		label.text = "[Locked]"

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if requires_key and not GameState.has_car13_key:
		_show_locked_message()
		return
	SceneTransition.go_to(target_scene)

func _show_locked_message() -> void:
	label.text = "The door is locked."

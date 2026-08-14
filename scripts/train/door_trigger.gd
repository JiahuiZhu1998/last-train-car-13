extends Area2D

# Door / transition trigger. Sends the player to another scene when they
# enter the area. Can require the Car 13 key and/or the accident clue.

@export var target_scene: String = "res://scenes/train/dining_car.tscn"
@export var requires_key: bool = false
@export var requires_clue: bool = false
@export var unlocks_car13: bool = false

@onready var label: Label = $DoorLabel

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if requires_key:
		label.text = "[Locked]"

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if requires_key and not GameState.has_car13_key:
		_show_message("The door is locked.")
		return
	if requires_clue and not GameState.found_accident_clue:
		_show_message("Something tells me I should learn what happened before entering.")
		return
	if unlocks_car13:
		GameState.car13_unlocked = true
	SceneTransition.go_to(target_scene)

func _show_message(text: String) -> void:
	label.text = text
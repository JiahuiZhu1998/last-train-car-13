extends Node2D

# A simple NPC that shows a dialogue balloon when interacted with.
# Interaction is detected when the player's InteractionArea overlaps this node's HitArea.

@export var dialogue_lines: Array[String] = [
	"Don't go to Car 13.",
	"No one comes back from there.",
]

var _line_index: int = 0
@onready var label: Label = $DialogueBalloon/Label
@onready var balloon: CanvasLayer = $DialogueBalloon

func interact() -> void:
	balloon.visible = true
	label.text = dialogue_lines[_line_index]
	_line_index = (_line_index + 1) % dialogue_lines.size()

func _unhandled_input(event: InputEvent) -> void:
	if balloon.visible and event.is_action_pressed("interact"):
		balloon.visible = false
		get_viewport().set_input_as_handled()

extends Node2D

# A simple NPC that shows / hides a dialogue balloon when interacted with.
# Interaction is detected when the player's InteractionArea overlaps this
# node's HitArea (collision layer 4). interact() toggles the balloon so the
# same key press never both opens and closes it in one frame.

@export var dialogue_lines: Array[String] = [
	"Don't go to Car 13.",
	"No one comes back from there.",
]

var _line_index: int = 0
@onready var label: Label = $DialogueBalloon/Label
@onready var balloon: CanvasLayer = $DialogueBalloon

func _ready() -> void:
	# Temporary gray-box visual: NPC is a green rectangle (only if a
	# Sprite2D is present, e.g. in the real scenes).
	var sp := get_node_or_null("Sprite2D")
	if sp != null:
		var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.2, 0.9, 0.3, 1.0))
		sp.texture = ImageTexture.create_from_image(img)

func interact() -> void:
	if balloon.visible:
		balloon.visible = false
		return
	balloon.visible = true
	label.text = dialogue_lines[_line_index]
	_line_index = (_line_index + 1) % dialogue_lines.size()
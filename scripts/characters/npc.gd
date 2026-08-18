extends Node2D

# A simple NPC that shows / hides a dialogue balloon when interacted with.
# Interaction is detected when the player's InteractionArea overlaps this
# node's HitArea (collision layer 4). interact() toggles the balloon so the
# same key press never both opens and closes it in one frame.
#
# The balloon styling is applied at runtime via DialogueStyle so the source
# scenes under scenes/train (gameplay/collision/triggers) stay unchanged.

const DialogueStyle := preload("res://scripts/ui/dialogue_style.gd")

@export var dialogue_lines: Array[String] = [
	"Don't go to Car 13.",
	"No one comes back from there.",
]

var _line_index: int = 0
@onready var label: Label = $DialogueBalloon/Label
@onready var balloon: CanvasLayer = $DialogueBalloon

func _ready() -> void:
	DialogueStyle.apply(balloon, label, _speaker_name())
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

# Use the scene's NpcLabel text (if present) as the speaker name, otherwise
# fall back to "PASSENGER". Purely visual; no node path is required.
func _speaker_name() -> String:
	var lp := get_node_or_null("NpcLabel") as Label
	# The in-scene NpcLabel is a debug placeholder ("NPC"), so only treat it as a
	# real name when it has been set to something else. Keeps the box clean.
	if lp != null and lp.text != "" and lp.text != "NPC":
		return lp.text
	return ""

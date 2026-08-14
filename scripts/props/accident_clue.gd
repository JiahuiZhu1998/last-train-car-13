extends Node2D

# Visible placeholder accident clue for the Dining Car. The player collects
# it once; doing so sets GameState.found_accident_clue, hides the visual, and
# shows the newspaper clipping as brief feedback. It never respawns.

@export var feedback_text: String = "Newspaper clipping:\nNight Express 13 derailed.\nNo survivors were reported."

@onready var pickup_area: Area2D = $PickupArea
@onready var visual: CanvasItem = $ClueVisual
@onready var feedback_label: Label = $FeedbackLabel

var active: bool = true

func _ready() -> void:
	feedback_label.visible = false
	if not GameState.found_accident_clue:
		visual.visible = true
		active = true
	else:
		visual.visible = false
		active = false
	if pickup_area != null:
		pickup_area.monitoring = active
		pickup_area.monitorable = active

func interact() -> void:
	if not active:
		return
	GameState.found_accident_clue = true
	active = false
	visual.visible = false
	if pickup_area != null:
		pickup_area.monitoring = false
		pickup_area.monitorable = false
	_show_feedback()

func _show_feedback() -> void:
	feedback_label.text = feedback_text
	feedback_label.visible = true
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(feedback_label):
		feedback_label.queue_free()
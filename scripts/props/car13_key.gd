extends Node2D

# Visible placeholder key for Passenger Car. The player collects it once;
# doing so sets GameState.has_car13_key, hides the visual, and shows a
# brief feedback label. It never respawns during the same run.

@export var feedback_text: String = "Obtained Car 13 Key."

@onready var pickup_area: Area2D = $PickupArea
@onready var visual: CanvasItem = $KeyVisual
@onready var feedback_label: Label = $FeedbackLabel

var active: bool = true

func _ready() -> void:
	feedback_label.visible = false
	if not GameState.has_car13_key:
		visual.visible = true
		active = true
	else:
		visual.visible = false
		active = false
	if pickup_area != null:
		pickup_area.monitoring = active
		pickup_area.monitorable = active
		pickup_area.body_entered.connect(_on_pickup_body_entered)

func _on_pickup_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	interact()

func interact() -> void:
	if not active:
		return
	GameState.has_car13_key = true
	active = false
	visual.visible = false
	if pickup_area != null:
		pickup_area.set_deferred("monitoring", false)
		pickup_area.set_deferred("monitorable", false)
	_show_feedback()

func _show_feedback() -> void:
	feedback_label.text = feedback_text
	feedback_label.visible = true
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(feedback_label):
		feedback_label.queue_free()
extends CanvasLayer

# Fades the permanent control hint in when the scene is entered and out after
# a few seconds. Purely presentational; movement / input logic stays in
# player.gd.

const HOLD_TIME := 3.0
const FADE_IN := 0.5
const FADE_OUT := 1.0

func _ready() -> void:
	var targets := []
	var alphas := []
	var panel := get_node_or_null("HintPanel")
	var label := get_node_or_null("Label")
	if panel is CanvasItem:
		targets.append(panel)
		alphas.append(panel.modulate.a)
	if label is CanvasItem:
		targets.append(label)
		alphas.append(label.modulate.a)
	for t in targets:
		t.modulate.a = 0.0
	var tween := create_tween()
	for i in targets.size():
		tween.tween_property(targets[i], "modulate:a", alphas[i], FADE_IN).from(0.0)
	tween.tween_interval(HOLD_TIME)
	for i in targets.size():
		tween.tween_property(targets[i], "modulate:a", 0.0, FADE_OUT)

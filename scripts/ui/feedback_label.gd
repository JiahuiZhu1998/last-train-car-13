extends Label

# Presentation-only fade-in for pickup feedback labels.
# The prop scripts (car13_key.gd / accident_clue.gd) still decide when the
# label is shown and freed; this script only animates the entrance so the
# plain Label reads as a polished sign. No gameplay, collision, or trigger
# logic is touched.

func _ready() -> void:
	modulate = Color(modulate.r, modulate.g, modulate.b, 0.0)
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if not visible:
		return
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3).from(0.0)

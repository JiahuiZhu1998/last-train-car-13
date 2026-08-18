# Shared visual styling for the in-world dialogue balloons shared by NPCs and
# the Conductor. The restyle is applied at runtime from the dialogue scripts so
# the source scenes under scenes/train stay byte-identical (gameplay, collision
# and triggers are out of scope for UI polish). The DialogueBalloon +`r`n# DialogueBalloon/Label node paths used by the dialogue scripts and the
# regression harness are preserved.

const ACCENT_CYAN := Color(0.25, 0.85, 1.0)
const ACCENT_RED := Color(1.0, 0.25, 0.35)
const PANEL := Color(0.07, 0.06, 0.11, 0.92)
const TEXT := Color(0.86, 0.89, 0.96)

static func apply(balloon: CanvasLayer, label: Label, speaker: String = "") -> void:
	if balloon == null or label == null:
		return

	var bg := balloon.get_node_or_null("BG") as ColorRect
	var left := 10.0
	var top := 10.0
	var right := 310.0
	var bottom := 65.0
	if bg != null:
		left = bg.offset_left
		top = bg.offset_top
		right = bg.offset_right
		bottom = bg.offset_bottom
		bg.color = PANEL

	var frame := ColorRect.new()
	frame.name = "Frame"
	frame.offset_left = left - 1
	frame.offset_top = top - 1
	frame.offset_right = right + 1
	frame.offset_bottom = bottom + 1
	frame.color = ACCENT_CYAN
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	balloon.add_child(frame)
	balloon.move_child(frame, 0)

	var bar := ColorRect.new()
	bar.name = "AccentBar"
	bar.offset_left = left
	bar.offset_top = top
	bar.offset_right = left + 3
	bar.offset_bottom = bottom
	bar.color = ACCENT_RED
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	balloon.add_child(bar)

	if speaker != "":
		var sp := Label.new()
		sp.name = "Speaker"
		sp.text = speaker
		sp.offset_left = left + 8
		sp.offset_top = top + 3
		sp.offset_right = right - 8
		sp.offset_bottom = top + 14
		sp.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		sp.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		sp.add_theme_color_override("font_color", ACCENT_CYAN)
		sp.add_theme_font_size_override("font_size", 9)
		balloon.add_child(sp)
		label.offset_left = left + 8
		label.offset_top = top + 16
		label.offset_right = right - 6
		label.offset_bottom = bottom - 4
	else:
		label.offset_left = left + 8
		label.offset_top = top + 4
		label.offset_right = right - 6
		label.offset_bottom = bottom - 4

	label.add_theme_color_override("font_color", TEXT)
	label.add_theme_font_size_override("font_size", 11)
	label.autowrap_mode = 3

	var hint := Label.new()
	hint.name = "ContinueHint"
	hint.text = "v"
	hint.offset_left = right - 14
	hint.offset_top = bottom - 12
	hint.offset_right = right - 4
	hint.offset_bottom = bottom - 2
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_color", ACCENT_CYAN)
	hint.add_theme_font_size_override("font_size", 10)
	balloon.add_child(hint)

	var tween := balloon.create_tween()
	tween.set_loops()
	tween.tween_property(hint, "modulate:a", 0.15, 0.6).from(1.0)
	tween.tween_property(hint, "modulate:a", 1.0, 0.6)

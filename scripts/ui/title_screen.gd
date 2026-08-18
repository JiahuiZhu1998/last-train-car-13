extends Control

# Minimal title screen. Start Game loads the main gameplay scene; Quit exits.

const MAIN_SCENE := "res://scenes/train/passenger_car.tscn"

@onready var btn_start: Button = $VBox/StartGame
@onready var btn_quit: Button = $VBox/Quit
@onready var title_label: Label = $VBox/Title
@onready var footer_label: Label = $Footer

func _ready() -> void:
	btn_start.pressed.connect(_on_start_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)
	# Subtle, irregular flicker on the title for the horror mood.
	var flicker := create_tween()
	flicker.set_loops()
	flicker.tween_property(title_label, "modulate:a", 0.65, 0.1).from(1.0)
	flicker.tween_property(title_label, "modulate:a", 1.0, 1.7)
	flicker.tween_property(title_label, "modulate:a", 0.85, 0.08).from(1.0)
	flicker.tween_property(title_label, "modulate:a", 1.0, 2.4)
	# Slow pulse on the footer tagline.
	var pulse := create_tween()
	pulse.set_loops()
	pulse.tween_property(footer_label, "modulate:a", 0.25, 1.1).from(0.7)
	pulse.tween_property(footer_label, "modulate:a", 0.7, 1.1)

func _on_start_pressed() -> void:
	SceneTransition.go_to(MAIN_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()

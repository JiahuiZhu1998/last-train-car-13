extends Control

# Minimal title screen. Start Game loads the main gameplay scene; Quit exits.

const MAIN_SCENE := "res://scenes/train/passenger_car.tscn"

@onready var btn_start: Button = $VBox/StartGame
@onready var btn_quit: Button = $VBox/Quit

func _ready() -> void:
	btn_start.pressed.connect(_on_start_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	SceneTransition.go_to(MAIN_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()

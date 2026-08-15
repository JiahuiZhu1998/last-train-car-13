extends Control

# Minimal game over screen. Restart returns to the Passenger Car.

const RESTART_SCENE := "res://scenes/train/passenger_car.tscn"

@onready var btn_restart: Button = $VBox/Restart

func _ready() -> void:
	btn_restart.pressed.connect(_on_restart_pressed)

func _on_restart_pressed() -> void:
	SceneTransition.go_to(RESTART_SCENE)

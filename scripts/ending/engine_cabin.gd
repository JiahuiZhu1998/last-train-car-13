extends Node2D

func _ready() -> void:
	GameState.ending_unlocked = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		get_tree().change_scene_to_file("res://scenes/train/passenger_car.tscn")

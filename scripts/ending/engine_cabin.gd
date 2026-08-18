extends Node2D

var _can_restart: bool = false

func _ready() -> void:
    GameState.ending_unlocked = true
    # Fade the whole cabin in from black for a somber reveal.
    modulate = Color(1, 1, 1, 0)
    var fade := create_tween()
    fade.tween_property(self, "modulate:a", 1.0, 1.4).from(0.0)
    await get_tree().create_timer(1.2).timeout
    _can_restart = true

func _unhandled_input(event: InputEvent) -> void:
    if not _can_restart:
        return
    if event is InputEventKey and event.pressed and not event.echo:
        get_tree().change_scene_to_file("res://scenes/train/passenger_car.tscn")

extends Node

# Minimal explicit game state for the vertical slice.
# Add flags here only when a scene actually needs to check them.

var has_car13_key: bool = false
var found_accident_clue: bool = false
var car13_unlocked: bool = false
var conductor_defeated: bool = false
var ending_unlocked: bool = false

# Pending combat data — set before switching to combat scene, cleared on return.
var pending_enemy: String = ""
var return_scene: String = ""
var return_position: Vector2 = Vector2.ZERO

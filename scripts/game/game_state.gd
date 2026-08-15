extends Node

# Minimal explicit game state for the vertical slice.
# Add flags here only when a scene actually needs to check them.

var has_car13_key: bool = false
var found_accident_clue: bool = false
var car13_unlocked: bool = false
var conductor_defeated: bool = false
var ending_unlocked: bool = false

# Pending combat data - set before switching to combat scene, cleared on return.
var pending_enemy: String = ""
var return_scene: String = ""
var return_position: Vector2 = Vector2.ZERO

# Per-run defeated normal encounters (by enemy_id). A trigger whose enemy_id is
# in this set is treated as already resolved: it does not fire combat and its
# visual/area is disabled on scene load. Cleared only on a fresh run. This is
# intentionally minimal — not a generalized encounter database.
var defeated_enemies: Dictionary = {}

func mark_enemy_defeated(enemy_id: String) -> void:
	if enemy_id != "" and not defeated_enemies.has(enemy_id):
		defeated_enemies[enemy_id] = true

func is_enemy_defeated(enemy_id: String) -> bool:
	return defeated_enemies.has(enemy_id)

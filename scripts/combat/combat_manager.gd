extends Node

# Minimal turn-based combat manager.
# Enemies are defined inline as data - no need for separate enemy scenes yet.

signal combat_ended(player_won: bool)

const ENEMY_DATA := {
	"shadow_passenger": {"name": "Shadow Passenger", "hp": 12, "attack": 3, "defense": 1},
	"crawling_thing":   {"name": "Crawling Thing",   "hp": 20, "attack": 5, "defense": 2},
	"the_conductor":    {"name": "The Conductor",    "hp": 45, "attack": 8, "defense": 3},
}

# Player stats (base values - no level-up system needed for vertical slice)
var player_hp: int = 30
var player_max_hp: int = 30
var player_attack: int = 7
var player_defense: int = 2
var player_guarding: bool = false

var enemy_id: String = ""
var enemy_hp: int = 0
var enemy_max_hp: int = 0
var enemy_attack: int = 0
var enemy_defense: int = 0
var enemy_name: String = ""

var _turn: String = "player"  # "player" or "enemy"
var _combat_active: bool = false

@onready var log_label: RichTextLabel = $UI/LogLabel
@onready var hp_label: Label = $UI/PlayerHP
@onready var enemy_hp_label: Label = $UI/EnemyHP
@onready var enemy_name_label: Label = $UI/EnemyName
@onready var action_buttons: VBoxContainer = $UI/Actions
@onready var btn_attack: Button = $UI/Actions/BtnAttack
@onready var btn_guard: Button = $UI/Actions/BtnGuard
@onready var btn_inspect: Button = $UI/Actions/BtnInspect

func _ready() -> void:
	enemy_id = GameState.pending_enemy
	if enemy_id == "" or not ENEMY_DATA.has(enemy_id):
		enemy_id = "shadow_passenger"

	var data: Dictionary = ENEMY_DATA[enemy_id]
	enemy_name = data["name"]
	enemy_hp = data["hp"]
	enemy_max_hp = data["hp"]
	enemy_attack = data["attack"]
	enemy_defense = data["defense"]

	btn_attack.pressed.connect(func(): _player_action("attack"))
	btn_guard.pressed.connect(func(): _player_action("guard"))
	btn_inspect.pressed.connect(func(): _player_action("inspect"))

	_combat_active = true
	_refresh_ui()
	_log("A %s appears!" % enemy_name)

func _player_action(action: String) -> void:
	if _turn != "player" or not _combat_active:
		return

	_set_buttons_enabled(false)
	player_guarding = false

	match action:
		"attack":
			var dmg: int = max(1, player_attack - enemy_defense)
			enemy_hp -= dmg
			_log("You attack for %d damage." % dmg)
		"guard":
			player_guarding = true
			_log("You brace yourself. Defense up this turn.")
		"inspect":
			_log(_get_inspect_text())

	_refresh_ui()

	if enemy_hp <= 0:
		_end_combat(true)
		return

	_turn = "enemy"
	await get_tree().create_timer(0.8).timeout
	_enemy_turn()

func _enemy_turn() -> void:
	if not _combat_active:
		return

	var defense := player_defense * (2 if player_guarding else 1)
	var dmg: int = max(1, enemy_attack - defense)
	player_hp -= dmg
	_log("%s attacks for %d damage!" % [enemy_name, dmg])
	_refresh_ui()

	if player_hp <= 0:
		_end_combat(false)
		return

	_turn = "player"
	_set_buttons_enabled(true)

func _end_combat(player_won: bool) -> void:
	_combat_active = false
	_set_buttons_enabled(false)

	if player_won:
		_log("You defeated the %s!" % enemy_name)
		if enemy_id == "the_conductor":
			GameState.conductor_defeated = true
			GameState.ending_unlocked = true
	else:
		_log("You have been defeated...")

	await get_tree().create_timer(1.5).timeout
	emit_signal("combat_ended", player_won)

	if player_won:
		SceneTransition.return_from_combat()
	else:
		# Reload the combat scene is not what we want on death - just return.
		# A proper game-over screen is Day 2 work.
		SceneTransition.return_from_combat()

func _refresh_ui() -> void:
	hp_label.text = "HP: %d / %d" % [player_hp, player_max_hp]
	enemy_hp_label.text = "%d / %d HP" % [enemy_hp, enemy_max_hp]
	enemy_name_label.text = enemy_name

func _set_buttons_enabled(enabled: bool) -> void:
	btn_attack.disabled = not enabled
	btn_guard.disabled = not enabled
	btn_inspect.disabled = not enabled

func _get_inspect_text() -> String:
	match enemy_id:
		"shadow_passenger":
			return "A dim silhouette of a traveler. It cannot remember its stop."
		"crawling_thing":
			return "Something that used to be human. Moving on all fours beneath the seats."
		"the_conductor":
			return "The Conductor. He believes the train must never stop."
		_:
			return "You study the enemy carefully."

func _log(text: String) -> void:
	log_label.text += text + "\n"
	# Auto-scroll
	await get_tree().process_frame
	log_label.scroll_to_line(log_label.get_line_count() - 1)

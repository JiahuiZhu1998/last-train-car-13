extends Node2D

@export var defeat_lines: Array[String] = [
    "You should have stayed in your seat.",
]

var _line_index: int = 0

@onready var boss_visual: CanvasItem = get_node("BossVisual")
@onready var boss_label: CanvasItem = get_node("BossLabel")
@onready var intro_label: CanvasItem = get_node("IntroLabel")
@onready var balloon: CanvasLayer = get_node("DialogueBalloon")
@onready var balloon_label: Label = get_node("DialogueBalloon/Label")
@onready var victory_feedback: CanvasItem = get_node("VictoryFeedback")

func _ready() -> void:
    if GameState.conductor_defeated:
        _hide_boss()
        if victory_feedback != null:
            victory_feedback.visible = true
        return
    if victory_feedback != null:
        victory_feedback.visible = false

func _hide_boss() -> void:
    if boss_visual != null:
        boss_visual.visible = false
    if boss_label != null:
        boss_label.visible = false
    if intro_label != null:
        intro_label.visible = false
    if balloon != null:
        balloon.visible = false

func interact() -> void:
    if GameState.conductor_defeated:
        return
    if balloon != null and balloon.visible:
        balloon.visible = false
        return
    if balloon != null:
        balloon.visible = true
        balloon_label.text = defeat_lines[_line_index]
        _line_index = (_line_index + 1) % defeat_lines.size()

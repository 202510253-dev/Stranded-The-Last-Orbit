extends Node2D

@export var guide_portrait: Texture2D = preload("res://assets/splashart/jinSplashArt.png")

@onready var player: CharacterBody2D = $Player
@onready var guide_npc: CharacterBody2D = $guide_npc
@onready var chat_panel: Control = $CanvasLayer/ChatPanel

var _finished := false

func _ready() -> void:
	Bgm.fade_in()
	player.set_movement_enabled(false)

	await move_guide_to_player()
	await play_dialogue()
	await tp_pc()
	await tutorial_dialogue()

	player.set_movement_enabled(true)
	_finished = true

func move_guide_to_player() -> void:
	var target_position := player.position + Vector2(16, 0)
	var tween := create_tween()
	tween.tween_property(guide_npc, "position", target_position, 1.0)
	await tween.finished

func play_dialogue() -> void:
	await show_line("Jin", "Welcome, You're the new engineer right?", guide_portrait)
	await show_line("Jin", "Welcome to Sputnik 2! Where we will launch the very first life on space which is our pet dog: LAIKA!", guide_portrait)
	await show_line("Jin", "Come! It's time to design our shuttle for Laika!", guide_portrait)

func tutorial_dialogue() -> void:
	await show_line("Jin", "use WASD for Movement and press 'E' to Interact", guide_portrait)
func tp_pc() -> void:
	var tween := create_tween()
	tween.tween_property(guide_npc, "position", Vector2(104, 121), 1.0)
	await tween.finished

func show_line(
	speaker_name: String,
	dialogue_text: String,
	portrait: Texture2D
) -> void:
	chat_panel.show_dialogue(speaker_name, dialogue_text, portrait)
	await chat_panel.dialogue_finished

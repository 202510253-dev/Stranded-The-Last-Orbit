extends Area2D

const GUIDE_PORTRAIT := preload("res://assets/splashart/jinSplashArt.png")

@onready var player = get_parent().get_node("Player")
@onready var chat_panel: Control = get_node("../CanvasLayer/ChatPanel")

var player_inside := false
var dialogue_active := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false

func _unhandled_input(event: InputEvent) -> void:
	if player_inside and not dialogue_active and event.is_action_pressed("interact"):
		start_dialogue()

func start_dialogue() -> void:
	dialogue_active = true
	player.set_movement_enabled(false)

	await show_line(
		"Jin",
		"Go to the computer and start designing our capsule for Laika.",
	)
	await show_line(
		"Jin",
		"Our capsule will ride on the R-7 rocket, which stands 98 ft tall and is about 10 ft wide.",
	)
	await show_line(
		"Jin",
		"The rocket alone weighs about 588,600 lb. With the capsule on top, the launch weight comes to about 589,750 lb.",
	)
	await show_line(
		"Jin",
		"One important detail: the capsule is not designed to separate from the rocket core, so the two go into orbit together.",
	)
	await show_line(
		"Jin",
		"That means the total weight in orbit is about 17,200 lb, since the core stays attached.",
	)
	await show_line(
		"Jin",
		"Laika weighs 13 lb. Make sure the combined weight of the capsule and Laika does not exceed 1,121 lb.",
	)
	await show_line(
		"Jin",
		"Press 'E' to interact with the computer and complete the required tasks.",
	)

	player.set_movement_enabled(true)
	dialogue_active = false

func show_line(speaker_name: String, dialogue_text: String) -> void:
	chat_panel.show_dialogue(speaker_name, dialogue_text, GUIDE_PORTRAIT)
	await chat_panel.dialogue_finished

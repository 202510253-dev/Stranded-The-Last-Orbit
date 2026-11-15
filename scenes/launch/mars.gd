extends Node2D

const ECHO_SPLASH_ART := preload("res://assets/splashart/Echo.png")
const LAIKA_SPLASH_ART := preload("res://assets/splashart/Laika.png")
const PLACEHOLDER_ART := preload("res://assets/splashart/PlaceHolder.png")

@onready var player: CharacterBody2D = $Player2
@onready var chat_panel: Control = $CanvasLayer/ChatPanel
@onready var fade_layer: ColorRect = $FadeCanvasLayer/FadeLayer

@export var landing_delay := 1.0
@export var fade_duration := 1.0

var _dialogue_active := false
var _dust_seen := false
var _path_seen := false
var _rocks_seen := false
var _ship_clicks := 0
var _warm_seen := false

func _ready() -> void:
	_connect_interactions()
	fade_layer.color.a = 1.0
	await get_tree().create_timer(landing_delay).timeout
	await _fade_from_black()
	await _play_landing_dialogue()

func _connect_interactions() -> void:
	for interaction_name in ["DustPatch", "WarmSpot"]:
		var interaction := get_node(interaction_name) as Area2D
		interaction.body_entered.connect(_on_walkable_interaction_entered.bind(interaction_name))
		interaction.input_event.connect(_on_interaction_input_event.bind(interaction_name))

	for interaction_name in ["Path", "Rocks", "Ship"]:
		var interaction := get_node(interaction_name) as Area2D
		interaction.input_event.connect(_on_interaction_input_event.bind(interaction_name))

func _play_landing_dialogue() -> void:
	await _show_line("Echo", "Come. Every living thing in history has only looked up at the Moon.")
	await _show_line("Echo", "Now you are here.")
	await _show_line("Echo", "The Moon is lighter than home. You weigh less here.")
	await _show_line("Echo", "That is why you leap. There is no air to carry sound, so the silence is real.")
	await _show_line("Echo", "And there is no air to carry heat away, which is why your first cabin grew so hot.")
	await _show_line("Echo", "In space, heat goes nowhere unless we give it somewhere to go.")
	await _show_line("Laika", "Cold, but something is different. Where is the warm?")
	await _show_line("Echo", "There is water on the Moon. Ancient ice, hidden in craters where the sun never touches.")
	await _show_line("Echo", "And tiny drops of it, even on the lit ground.")

func _on_walkable_interaction_entered(body: Node2D, interaction_name: String) -> void:
	if body != player or _dialogue_active:
		return

	if interaction_name == "DustPatch":
		_show_dust_dialogue()
	elif interaction_name == "WarmSpot":
		_show_warm_dialogue()

func _on_interaction_input_event(
	viewport: Viewport,
	event: InputEvent,
	_shape_index: int,
	interaction_name: String
) -> void:
	if not event is InputEventMouseButton:
		return

	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return

	viewport.set_input_as_handled()
	if _dialogue_active:
		return

	match interaction_name:
		"Path":
			_show_path_dialogue()
		"Rocks":
			_show_rocks_dialogue()
		"Ship":
			_show_ship_dialogue()
		"WarmSpot":
			_show_warm_dialogue()
		"DustPatch":
			_show_dust_dialogue()

func _show_dust_dialogue() -> void:
	if _dust_seen:
		return
	_dust_seen = true
	await _show_line("Echo", "Laika steps off the path and her paws sink into a pale, powdery patch.")
	await _show_line("Echo", "It rises in a slow puff and settles.")
	await _show_line("Echo", "That is Moon dust. Soft and powdery.")
	await _show_line("Echo", "It looks gentle, but it makes this place hard for explorers, human and machine.")
	await _show_line("Laika", "Dirty paws. I will clean them later.")

func _show_path_dialogue() -> void:
	if _path_seen:
		return
	_path_seen = true
	await _show_line("Laika", "Someone walked here. Or will walk.")

func _show_rocks_dialogue() -> void:
	if _rocks_seen:
		return
	_rocks_seen = true
	await _show_line("Laika", "It has nice edges. Good for sniffing.")

func _show_ship_dialogue() -> void:
	if _ship_clicks >= 2:
		return
	_ship_clicks += 1
	if _ship_clicks == 1:
		await _show_line("Laika", "My cabin. It feels far away now.")
		await _show_line("Echo", "In about three years, other animals will orbit Earth and come home alive. Their flights will be the first steps toward sending a human into space.")
	else:
		await _show_line("Echo", "A man who will one day lead America's human spaceflight center will watch your launch and realize a program to send people to space is coming.")
		await _show_line("Laika", "I miss my bowl.")

func _show_warm_dialogue() -> void:
	if _warm_seen:
		return
	_warm_seen = true
	await _show_line("Laika", "The ground is warm here.")
	await _show_line("Echo", "Not that way, little one. Not yet.")

func _show_line(speaker_name: String, dialogue_text: String) -> void:
	_dialogue_active = true
	player.set_movement_enabled(false)
	var portrait := ECHO_SPLASH_ART
	if speaker_name == "Laika":
		portrait = LAIKA_SPLASH_ART
	elif speaker_name == "Narration":
		portrait = PLACEHOLDER_ART
	chat_panel.show_dialogue(speaker_name, dialogue_text, portrait)
	await chat_panel.dialogue_finished
	player.set_movement_enabled(true)
	_dialogue_active = false

func _fade_from_black() -> void:
	var fade := create_tween()
	fade.tween_property(fade_layer, "color:a", 0.0, fade_duration)
	await fade.finished

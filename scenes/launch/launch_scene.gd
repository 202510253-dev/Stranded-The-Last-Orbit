extends Node2D

const GUIDE_PORTRAIT := preload("res://assets/splashart/jinSplashArt.png")

@export var trivia_scene: PackedScene
@export var launch_speed := 20.0
@export var launch_height := 160.0
@export var transition_duration := 0.8
@export var camera_pan_duration := 1.2
@export var fade_duration := 1.0

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var rocket: TileMapLayer = $Rocket
@onready var flying_rocket: AnimatedSprite2D = $AnimatedSprite2D
@onready var chat_panel: Control = $CanvasLayer/ChatPanel
@onready var guide_area: Area2D = $Area2D
@onready var fade_layer: ColorRect = $FadeCanvasLayer/FadeLayer

var player_inside := false
var dialogue_active := false
var launch_started := false

func _ready() -> void:
	dialogue_active = true
	player.set_movement_enabled(false)
	flying_rocket.visible = false
	fade_layer.color.a = 1.0
	guide_area.body_entered.connect(_on_guide_area_body_entered)
	guide_area.body_exited.connect(_on_guide_area_body_exited)
	await _fade_from_black()
	player.set_movement_enabled(true)
	dialogue_active = false

func _on_guide_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true

func _on_guide_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false

func _unhandled_input(event: InputEvent) -> void:
	if player_inside and not dialogue_active and not launch_started and event.is_action_pressed("interact"):
		_start_launch_sequence()

func _start_launch_sequence() -> void:
	dialogue_active = true
	launch_started = true
	player.set_movement_enabled(false)

	await _play_launch_dialogue()
	await _pan_camera_to_rocket()
	await _launch_rocket()
	await _finish_launch()

func _play_launch_dialogue() -> void:
	await _show_line("Jin", "The rocket is ready. Laika is safe inside and we are clear to launch.")
	await _show_line("Jin", "Stand back! The new engines will lift us straight up.")
	await _show_line("Jin", "Three... two... one... launch!")

func _show_line(speaker_name: String, dialogue_text: String) -> void:
	chat_panel.show_dialogue(speaker_name, dialogue_text, GUIDE_PORTRAIT)
	await chat_panel.dialogue_finished

func _pan_camera_to_rocket() -> void:
	var rocket_camera_position := flying_rocket.position - player.position
	var pan := create_tween()
	pan.tween_property(camera, "position", rocket_camera_position, camera_pan_duration)
	await pan.finished

func _launch_rocket() -> void:
	flying_rocket.position = Vector2(262.0, 80.0)
	flying_rocket.visible = true
	flying_rocket.modulate.a = 0.0
	flying_rocket.frame = 0
	flying_rocket.play("default")

	var transition := create_tween().set_parallel(true)
	transition.tween_property(rocket, "modulate:a", 0.0, transition_duration)
	transition.tween_property(flying_rocket, "modulate:a", 1.0, transition_duration)
	await transition.finished

	var flight_duration := launch_height / launch_speed
	var flight := create_tween()
	flight.tween_property(
		flying_rocket,
		"position:y",
		flying_rocket.position.y - launch_height,
		flight_duration
	).set_trans(Tween.TRANS_LINEAR)
	await flight.finished

func _finish_launch() -> void:
	if trivia_scene == null:
		push_error("Trivia scene is not assigned to the launch scene.")
		player.set_movement_enabled(true)
		dialogue_active = false
		return

	await _fade_to_black()
	get_tree().change_scene_to_packed(trivia_scene)

func _fade_from_black() -> void:
	var fade := create_tween()
	fade.tween_property(fade_layer, "color:a", 0.0, fade_duration)
	await fade.finished

func _fade_to_black() -> void:
	var fade := create_tween()
	fade.tween_property(fade_layer, "color:a", 1.0, fade_duration)
	await fade.finished

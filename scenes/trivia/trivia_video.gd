extends Control

signal finished

const SPACESHIP_SCENE := preload("res://scenes/test/SpaceShip.tscn")

@export var fade_duration := 1.0

@onready var chat_panel: Control = $CanvasLayer/ChatPanel
@onready var video_player: VideoStreamPlayer = $VideoPlayer
@onready var fade_layer: ColorRect = %FadeLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	video_player.finished.connect(_on_video_finished)
	video_player.modulate.a = 0.0
	video_player.volume = 0.0
	fade_layer.color.a = 1.0
	await _fade_from_black()
	await _show_trivia()

func _show_trivia() -> void:
	chat_panel.show_dialogue(
		"Echo",
		"Did you know Sputnik 2, the capsule built for Laika, was made in under 4 weeks?"
	)
	await chat_panel.dialogue_finished
	chat_panel.show_dialogue(
		"Echo",
		"..."
	)
	await chat_panel.dialogue_finished

	if video_player.stream == null:
		push_error("Trivia video stream is not assigned.")
		_finish()
		return

	video_player.show()
	video_player.play()
	var video_fade := create_tween().set_parallel(true)
	video_fade.tween_property(video_player, "modulate:a", 1.0, fade_duration)
	video_fade.tween_property(video_player, "volume", 1.0, fade_duration)

func _on_video_finished() -> void:
	await _fade_to_black()
	_finish()

func _fade_from_black() -> void:
	var tween := create_tween()
	tween.tween_property(fade_layer, "color:a", 0.0, fade_duration)
	await tween.finished

func _fade_to_black() -> void:
	var tween := create_tween()
	tween.tween_property(fade_layer, "color:a", 1.0, fade_duration)
	await tween.finished

func _finish() -> void:
	finished.emit()
	get_tree().change_scene_to_packed(SPACESHIP_SCENE)

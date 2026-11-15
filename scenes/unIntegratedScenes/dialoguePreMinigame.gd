extends Control

const MARS_SCENE_PATH := "res://scenes/launch/mars.tscn"

signal startMinigame

@onready var chat_panel: Control = $CanvasLayer/ChatPanel
@onready var fade_layer: ColorRect = $"../FadeCanvasLayer/FadeLayer"

@export var fade_duration := 0.8

var _transitioning := false

func _on_minigame_asteroid_start_dialogue() -> void:
	await _fade_from_black()
	await _show_line("Echo", "The sky is moving.")
	await _show_line("Echo", "Keep Laika safe and clear the path.")
	startMinigame.emit()

func _on_minigame_asteroid_fade_out() -> void:
	if _transitioning:
		return
	_transitioning = true
	var fade := create_tween()
	fade.tween_property(fade_layer, "color:a", 1.0, fade_duration)
	await fade.finished
	var error := get_tree().change_scene_to_file(MARS_SCENE_PATH)
	if error != OK:
		_transitioning = false
		push_error("Could not load Mars scene: %s" % error)

func _show_line(speaker_name: String, dialogue_text: String) -> void:
	chat_panel.show_dialogue(speaker_name, dialogue_text)
	await chat_panel.dialogue_finished

func _fade_from_black() -> void:
	fade_layer.color.a = 1.0
	var fade := create_tween()
	fade.tween_property(fade_layer, "color:a", 0.0, fade_duration)
	await fade.finished

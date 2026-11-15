extends Area2D

const GUIDE_PORTRAIT := preload("res://assets/splashart/jinSplashArt.png")

@export var minigame_scene: PackedScene
@export var trivia_scene: PackedScene
@export var transition_duration := 1.0

@onready var chat_panel: Control = get_node("../CanvasLayer/ChatPanel")

var player_inside := false
var minigame: Node = null
var _transitioning := false

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
	if player_inside and minigame == null and event.is_action_pressed("interact"):
		open_minigame()

func open_minigame() -> void:
	if minigame_scene == null:
		push_error("Minigame scene is not assigned to event0.")
		return

	minigame = minigame_scene.instantiate()
	get_tree().current_scene.add_child(minigame)
	minigame.completed.connect(_on_minigame_completed)
	get_tree().paused = true

func _on_minigame_completed() -> void:
	if _transitioning:
		return

	_transitioning = true
	if is_instance_valid(minigame):
		minigame.queue_free()
	minigame = null

	if trivia_scene == null:
		push_error("Trivia scene is not assigned to event0.")
		get_tree().paused = false
		_transitioning = false
		return

	get_tree().paused = false
	chat_panel.show_dialogue(
		"Jin",
		"Looks Good To Me! We will see it launch in a few weeks",
		GUIDE_PORTRAIT
	)
	await chat_panel.dialogue_finished
	await _fade_to_black()
	get_tree().change_scene_to_packed(trivia_scene)

func _fade_to_black() -> void:
	var fade_layer := CanvasLayer.new()
	fade_layer.layer = 200
	get_tree().current_scene.add_child(fade_layer)

	var fade_rect := ColorRect.new()
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	fade_layer.add_child(fade_rect)

	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, transition_duration)
	await tween.finished

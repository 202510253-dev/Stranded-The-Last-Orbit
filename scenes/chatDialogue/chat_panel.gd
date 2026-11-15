extends Control

signal dialogue_finished

@export var close_on_advance := true
@export var transition_duration := 0.25

@onready var splash_art: TextureRect = $MarginContainer/HBoxContainer/SplashArt
@onready var name_label: Label = $MarginContainer/HBoxContainer/Content/Name
@onready var text_label: Label = $MarginContainer/HBoxContainer/Content/Text

var _is_showing := false
var _transition_id := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	modulate.a = 0.0

func show_dialogue(
	speaker_name: String,
	dialogue_text: String,
	portrait: Texture2D = null
) -> void:
	name_label.text = speaker_name
	text_label.text = dialogue_text

	if portrait != null:
		splash_art.texture = portrait

	_transition_id += 1
	_is_showing = true
	visible = true
	var transition := create_tween()
	transition.tween_property(self, "modulate:a", 1.0, transition_duration)

func hide_dialogue() -> void:
	if not _is_showing:
		return

	_transition_id += 1
	var transition_id := _transition_id
	_is_showing = false
	var transition := create_tween()
	transition.tween_property(self, "modulate:a", 0.0, transition_duration)
	await transition.finished

	if transition_id == _transition_id:
		visible = false
		dialogue_finished.emit()

func _input(event: InputEvent) -> void:
	if not _is_showing or not close_on_advance:
		return

	var should_advance := event.is_action_pressed("interact")

	if event is InputEventMouseButton:
		should_advance = (
			event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		)
	elif event is InputEventScreenTouch:
		should_advance = event.pressed

	if should_advance:
		get_viewport().set_input_as_handled()
		hide_dialogue()

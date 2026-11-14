extends Control

signal dialogue_finished

@export var close_on_advance := true

@onready var splash_art: TextureRect = $MarginContainer/HBoxContainer/SplashArt
@onready var name_label: Label = $MarginContainer/HBoxContainer/Content/Name
@onready var text_label: Label = $MarginContainer/HBoxContainer/Content/Text

var _is_showing := false

func _ready() -> void:
	visible = false

func show_dialogue(
	speaker_name: String,
	dialogue_text: String,
	portrait: Texture2D = null
) -> void:
	name_label.text = speaker_name
	text_label.text = dialogue_text

	if portrait != null:
		splash_art.texture = portrait

	_is_showing = true
	visible = true

func hide_dialogue() -> void:
	if not _is_showing:
		return

	_is_showing = false
	visible = false
	dialogue_finished.emit()

func _unhandled_input(event: InputEvent) -> void:
	if _is_showing and close_on_advance and event.is_action_pressed("interact"):
		hide_dialogue()

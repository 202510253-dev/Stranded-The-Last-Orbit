extends Control

signal disclaimer_finished

const SPACESHIP_SCENE := preload("res://scenes/test/SpaceShip.tscn")

@export var fade_duration := 1.0
@export var radio_static_stream: AudioStream

@onready var chat_panel: Control = $CanvasLayer/ChatPanel
@onready var fade_layer: ColorRect = %FadeLayer
@onready var radio_player: AudioStreamPlayer = $RadioStatic

var _radio_playback: AudioStreamGeneratorPlayback

var _lines := [
	"The journey to the Moon and Mars, Echo, and the imagined return depicted in this game are fictional elements created for storytelling.",
	"Laika's actual mission was aboard Sputnik 2, launched on November 3, 1957. The spacecraft did not travel to the Moon or Mars and had no recovery system.",
	"Laika died several hours after launch due to overheating and stress.",
	"Her death was not caused by a return journey. The exact circumstances and timing were initially misrepresented and later clarified.",
	"This is not the story of how Laika came home. It is the story of a little dog who never stopped looking for it."
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	fade_layer.color.a = 1.0
	_start_radio_static()
	radio_player.volume_db = -40.0
	await get_tree().create_timer(1.0).timeout
	await _fade_from_black()
	await _play_developer_dialogue()
	await _fade_to_black()
	_instantiate_spaceship()

func _process(_delta: float) -> void:
	if _radio_playback == null:
		return

	var frames_available := _radio_playback.get_frames_available()
	for _frame in frames_available:
		var static_sample := randf_range(-0.08, 0.08)
		if randf() < 0.002:
			static_sample += randf_range(-0.25, 0.25)
		_radio_playback.push_frame(Vector2(static_sample, static_sample))

func _start_radio_static() -> void:
	if radio_static_stream != null:
		radio_player.stream = radio_static_stream
		radio_player.play()
		return

	var generator := AudioStreamGenerator.new()
	generator.mix_rate = 44100.0
	generator.buffer_length = 1.0
	radio_player.stream = generator
	radio_player.play()
	_radio_playback = radio_player.get_stream_playback()

func _play_developer_dialogue() -> void:
	for line in _lines:
		await _show_line(line)

func _show_line(dialogue_text: String) -> void:
	chat_panel.show_dialogue("Echo", dialogue_text)
	await chat_panel.dialogue_finished

func _fade_from_black() -> void:
	var tween := create_tween()
	tween.tween_property(fade_layer, "color:a", 0.0, fade_duration)
	tween.parallel().tween_property(radio_player, "volume_db", -20.0, fade_duration)
	await tween.finished

func _fade_to_black() -> void:
	var tween := create_tween()
	tween.tween_property(fade_layer, "color:a", 1.0, fade_duration)
	tween.parallel().tween_property(radio_player, "volume_db", -60.0, fade_duration)
	await tween.finished

func _instantiate_spaceship() -> void:
	var spaceship := SPACESHIP_SCENE.instantiate()
	get_tree().root.add_child(spaceship)
	get_tree().current_scene = spaceship
	disclaimer_finished.emit()
	queue_free()

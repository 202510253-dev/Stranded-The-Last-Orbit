extends AudioStreamPlayer

@export var target_volume_db := -15.0

var _fade_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	volume_db = -80.0

func fade_in(duration: float = 1.0) -> void:
	if not playing:
		play()
	_fade_to(target_volume_db, duration)

func fade_out(duration: float = 2.0) -> void:
	if not playing:
		return
	await _fade_to(-80.0, duration)
	stop()

func _fade_to(target: float, duration: float) -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "volume_db", target, duration)
	await _fade_tween.finished

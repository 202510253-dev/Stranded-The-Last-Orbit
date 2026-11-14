extends Area2D

signal destroyMeteor(meteor)
var meteor

func _ready() -> void:
	var meteor = get_node("Meteor")
# Called when the node enters the scene tree for the first time.
func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("mouseLeftClick"):
		print("Meteor Pressed")
		emit_signal("destroyMeteor")

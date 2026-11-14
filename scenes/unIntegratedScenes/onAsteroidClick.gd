extends Area2D

signal asteroidClick
	
func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("mouseLeftClick"):
		print("Asteroid Clicked!")
		emit_signal("asteroidClick")
		

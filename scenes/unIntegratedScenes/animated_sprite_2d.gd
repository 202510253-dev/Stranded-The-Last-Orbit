extends AnimatedSprite2D

var asteroidInstance

signal destroy_asteroid

func _ready() -> void:
	var id = get_instance_id()
	asteroidInstance = instance_from_id(id)
	play("asteroid")
	
func _process(_delta: float) -> void:
	pass

func _on_area_2d_asteroid_click() -> void:
#	print("To Animate Signal Received!")
	play("destroid")
	asteroidInstance.animation_finished
		

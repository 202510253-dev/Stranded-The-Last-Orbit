extends AnimatedSprite2D

var asteroidInstance

func _ready() -> void:
	var id = get_instance_id()
	asteroidInstance = instance_from_id(id)
	play("asteroid")
	
	
func _process(_delta: float) -> void:
	pass

func asteroidInteract():
	asteroidInstance.play("destroid")
	$AudioStreamPlayer2D.play()
	$Area2D/CollisionShape2D.disabled = true
	
func _on_area_2d_asteroid_click() -> void:
#	print("To Animate Signal Received!")
	asteroidInteract()

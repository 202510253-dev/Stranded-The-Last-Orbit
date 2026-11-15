extends RigidBody2D

var asteroidInstance

func _ready() -> void:
	var id = get_instance_id()
	asteroidInstance = instance_from_id(id)

func removeAsteroid() -> void:
	asteroidInstance.queue_free()

func _on_animated_sprite_2d_animation_finished() -> void:
	#print("Signal to remove asteroid received")
	removeAsteroid()

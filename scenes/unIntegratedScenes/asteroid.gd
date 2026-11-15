extends RigidBody2D

var asteroidInstance

func _ready() -> void:
	var id = get_instance_id()
	asteroidInstance = instance_from_id(id)
	$CollisionShape2D.disabled = false

func removeAsteroid() -> void:
	asteroidInstance.queue_free()

func _on_animated_sprite_2d_animation_finished() -> void:
	#print("Signal to remove asteroid received")
	removeAsteroid()

func _on_area_2d_area_entered(_area: Area2D) -> void:
	$AnimatedSprite2D.asteroidInteract()

extends RigidBody2D

var asteroidInstance

func _ready() -> void:
	var id = get_instance_id()
	asteroidInstance = instance_from_id(id)

func removeAsteroid() -> void:
	asteroidInstance.queue_free()

func _on_area_2d_asteroid_click() -> void:
	print("Signal Received!")
	removeAsteroid()

func _on_body_entered(body: Node) -> void:
	removeAsteroid()

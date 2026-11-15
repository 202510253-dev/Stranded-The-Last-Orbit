extends CharacterBody2D
signal hit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Checks if the character is hit by a RigidBody2D Node
# Which, would be the meteor
func _on_body_entered(body: Node2D) -> void:
	hide()
	print("Character Hit!")
	$CollisionShape2D.set_deferred("disabled", true)

# Enables the character on function call in specified position
func start(pos):
	position = pos
	show()
	$CollisionShape2D.set_deferred("disabled", false)

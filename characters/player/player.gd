extends CharacterBody2D

@export var speed: float = 100.0
@export var can_move := true

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var facing: String = "Down"

func _physics_process(_delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		update_animation(Vector2.ZERO)
		return

	var direction := Input.get_vector("walkLeft", "walkRight", "walkUp", "walkDown")
	velocity = direction * speed
	move_and_slide()
	update_animation(direction)

func set_movement_enabled(enabled: bool) -> void:
	can_move = enabled

func update_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		# Moving: pick the dominant axis, then play the walk animation
		if abs(direction.x) > abs(direction.y):
			facing = "Right" if direction.x > 0 else "Left"
		else:
			facing = "Down" if direction.y > 0 else "Up"
		anim.play("walk" + facing)
	else:
		# Standing still: play the idle animation for the last facing direction
		anim.play("idle" + facing)

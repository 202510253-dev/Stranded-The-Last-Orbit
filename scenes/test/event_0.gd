extends Area2D

@export var minigame_scene: PackedScene
var player_inside := false
var minigame: Node = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false

func _unhandled_input(event: InputEvent) -> void:
	if player_inside and minigame == null and event.is_action_pressed("interact"):
		open_minigame()

func open_minigame() -> void:
	if minigame_scene == null:
		push_error("Minigame scene is not assigned to event0.")
		return

	minigame = minigame_scene.instantiate()
	get_tree().current_scene.add_child(minigame)
	minigame.completed.connect(_on_minigame_completed)
	get_tree().paused = true

func _on_minigame_completed() -> void:
	if is_instance_valid(minigame):
		minigame.queue_free()
	minigame = null
	get_tree().paused = false

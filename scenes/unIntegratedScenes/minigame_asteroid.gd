extends Node2D

@export var asteroid_scene: PackedScene
@export var health = 3

@export var minVelocity = 67.0;
@export var maxVelocity = 100.0;

var currentHealth = health

func _ready() -> void:
	new_game()

func _on_rocket_hit() -> void:
	currentHealth -= 1
	if (currentHealth == 0):
		game_over()

func game_over() -> void:
	$SpawnRate.stop()
	set_process_input(false)

func new_game() -> void:
	currentHealth = health
	$Rocket.start($RocketPosition.position)
	$SpawnRate.start()


func _on_spawn_rate_timeout() -> void:
	var asteroid = asteroid_scene.instantiate()
	
	var asteroid_spawn_location = $AsteroidSpawnerPerimeter/AsteroidSpawnLocation
	asteroid_spawn_location.progress_ratio = randf()
	
	asteroid.position = asteroid_spawn_location.position
	
	var direction = asteroid_spawn_location.rotation + PI / 2
	
	direction += randf_range(-PI / 4, PI / 4)
	asteroid.rotation = direction
	
	var velocity = Vector2(randf_range(minVelocity, maxVelocity), 0.0)
	asteroid.linear_velocity = velocity.rotated(direction)
	
	add_child(asteroid)

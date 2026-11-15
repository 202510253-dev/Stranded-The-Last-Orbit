extends Area2D

signal hit

@export var health := 4 #modifiable health
var rocketInstance #used to determine the specific Object instance

func _ready() -> void:
	var id = get_instance_id() #gets unique id of Object Instance
	rocketInstance = instance_from_id(id) #returns Object reference
	$Sprite2D.play("Rocket")

# removes rocket from the scene
func removeRocket() -> void:
	rocketInstance.queue_free()

#add new code either here or above
#that would occur if health == 0
func checkHealth() -> void:
	if (health == 0):
		removeRocket()
	
func _process(delta: float) -> void:
	checkHealth()
	
func start(pos):
	position = pos
	show()
	$Hurtbox.disabled = false


func _on_body_entered(body: Node2D) -> void:
	health -= 1

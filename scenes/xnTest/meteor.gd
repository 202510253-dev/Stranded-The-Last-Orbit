extends RigidBody2D


				
				


func _on_area_2d_destroy_meteor() -> void:
	print("Meteor Destroyed")
	queue_free()

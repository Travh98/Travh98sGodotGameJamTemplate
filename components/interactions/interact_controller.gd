extends Node

## Controls a raycast to allow players to interact with anything that has
## the on_interact function

@export var interact_cast: RayCast3D

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		var hit_object = interact_cast.get_collider()
		if hit_object != null:
			if hit_object.has_method("on_interact"):
				hit_object.on_interact()
				print("Interacting with ", hit_object)

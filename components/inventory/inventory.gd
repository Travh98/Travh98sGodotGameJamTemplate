extends Node
class_name BaseInventory

@export var right_hand: Node3D
var weapon_right: Gun
@export var left_hand: Node3D

const DEV_RIFLE = preload("res://props/dev_rifle.tscn")

func _ready():
	if right_hand == null:
		push_warning("No right hand set for inventory")
	else:
		var rifle = DEV_RIFLE.instantiate()
		right_hand.add_child(rifle)
		rifle.position = right_hand.position
		rifle.rotation = Vector3(deg_to_rad(0.1), deg_to_rad(-105.8), deg_to_rad(11.1)) # force gun to line up with hand
		weapon_right = rifle
	
	

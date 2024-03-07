extends Node3D

@export var respawn_pos: LocationIndicator
var player: FpsCharacter

func _ready():
	var all_nodes = []
	GameMgr.GetAllTreeNodes(self, all_nodes)
	for node in all_nodes:
		if node is FpsCharacter:
			player = node


func _input(_event):
	if Input.is_action_just_pressed("restart_scene"):
		if weakref(player).get_ref():
			player.global_position = respawn_pos.global_position
			player.global_rotation = respawn_pos.global_rotation
			player.velocity = Vector3.ZERO

extends Node

## Singleton for managing the game

# The current scene that owns the game and is a child of root
var current_game_scene: Node
var current_level_parent: Node

# Global boolean for pausing anything important, while allowing animations to play
var do_process_actions: bool = true : set = set_process_actions
var played_once: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
	# Note: Also set Dialogic's default_layout_base canvas scene to Always Process
	
	# Pause the game's important actions when in dialog, like AI movement / combat
	# If you want to allow it, just call timeline_allow_actions at the start of dialog
	Dialogic.timeline_started.connect(timeline_pause_actions)
	Dialogic.timeline_ended.connect(timeline_allow_actions)
	
	# We will spawn levels as a child of this node
	current_level_parent = get_tree().root.get_node("GameTree/CurrentLevel")


func pause_game():
	get_tree().paused = true


func unpause_game():
	get_tree().paused = false


func change_scene(level_name: String) -> bool:
	var next_scene_path = "res://levels/" + level_name + ".tscn"
	if FileAccess.file_exists(next_scene_path):
		#print("Changing scene to: ", level_name)
		
		# Load the new scene
		var NewLevel: PackedScene = load(next_scene_path)
		var new_level: Node3D = NewLevel.instantiate()
		
		# Remove existing scene
		for level in current_level_parent.get_children():
			level.queue_free.call_deferred()
		current_game_scene = new_level
		
		current_level_parent.add_child.call_deferred(new_level)
		return true
	else:
		push_warning("Could not find scene to transition to: ", next_scene_path)
		return false


#func enter_area_change_scene(level_name: String, location_name: String):
	#if change_scene(level_name):
		## Do things on success
		##spawn_player_in_new_level.call_deferred(location_name)
		#move_player_to_enter_location.call_deferred(level_name, location_name)
		#pass


#func move_player_to_enter_location(level_name: String, location_name: String):
	#var player
	#var location: LocationIndicator
	#
	#for child in GetAllTreeNodes():
		#if child is Mob:
			#if child.has_node("PlayerController"):
				#player = child
		#
		#if child is LocationIndicator:
			#if child.location_name == location_name:
				#location = child
	#
	#if weakref(player).get_ref() and location != null:
		#player.global_position = location.global_position
		#player.global_rotation = location.global_rotation
	#else:
		#push_warning("Failed to find location: ", location_name, " or player in level: ", level_name)


func set_process_actions(do_process: bool):
	do_process_actions = do_process
	#print("Processing Actions: ", do_process_actions)


func timeline_pause_actions():
	set_process_actions(false)


func timeline_allow_actions():
	set_process_actions(true)


func GetAllTreeNodes(node = get_tree().root, listOfAllNodesInTree = []):
	listOfAllNodesInTree.append(node)
	for childNode in node.get_children():
		GetAllTreeNodes(childNode, listOfAllNodesInTree)
	return listOfAllNodesInTree


func print_root_children():
	for child in get_tree().root.get_children():
		print("Tree root child: ", child)


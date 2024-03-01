extends Control

## Global Autoload Manager for User Interface

@onready var overworld_hud: Control = $Hud
@onready var overworld_pause_menu: Control = $PauseMenu


var is_paused: bool = false
var backpack_inventory: Node3D


func _ready():
	pass


func _input(_event):
	if Input.is_action_just_pressed(&"menu"):
		if is_paused:
			unpause_game()
		else:
			# Don't pause the game if we're not supposed to be processing (Dialog or cutscenes)
			if GameMgr.do_process_actions:
				pause_game()


func pause_game():
	overworld_pause_menu.visible = true
	overworld_hud.visible = false
	GameMgr.set_process_actions(false)
	
	is_paused = true


func unpause_game():
	overworld_pause_menu.visible = false
	overworld_hud.visible = true
	GameMgr.set_process_actions(true)
	
	if weakref(backpack_inventory).get_ref():
		backpack_inventory.despawn()
	
	is_paused = false


func on_sticker_start_menu_done():
	# Remove the backpack, as its in the way
	if weakref(backpack_inventory).get_ref():
		backpack_inventory.queue_free()
	
	sticker_start_menu.visible = false


func on_sticker_placing_done():
	# Return to being paused
	pause_game()

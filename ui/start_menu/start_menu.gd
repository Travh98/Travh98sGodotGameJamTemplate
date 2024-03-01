extends Control

@onready var start_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/StartButton
@onready var settings_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/SettingsButton
@onready var credits_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/CreditsButton
@onready var quit_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/QuitButton

@onready var start_menu_buttons: Control = $MarginContainer
@onready var credits: Control = $Credits

@export var next_scene_path: String = "res://levels/test_level.tscn"


func _ready():
	start_button.pressed.connect(load_next_scene)
	#settings_button.pressed.connect(show_settings_menu)
	credits_button.pressed.connect(show_credits)
	quit_button.pressed.connect(quit)
	
	credits.close_credits.connect(on_credits_closed)


func load_next_scene():
	#GameManager.change_level(next_scene_path)
	queue_free()


func show_credits():
	credits.visible = true
	start_menu_buttons.visible = false


func on_credits_closed():
	credits.visible = false
	start_menu_buttons.visible = true


func quit():
	get_tree().quit()

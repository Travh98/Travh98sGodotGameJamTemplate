extends Control

signal close_credits
@onready var return_button: Button = $MarginContainer/VBoxContainer/ReturnButton

func _ready():
	return_button.pressed.connect(on_exit_credits)


func on_exit_credits():
	visible = false
	close_credits.emit()

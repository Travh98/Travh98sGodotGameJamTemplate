class_name HealthComponent
extends Node

## A component for managing Health

signal health_changed(health_value: int)
signal health_died

@export var health: int = 100
@export var max_health: int = 100
var invincible: bool = false
var is_dead: bool = false


func _ready():
	pass


func take_damage(damage: int):
	if invincible:
		return
	update_health(get_health() - damage)


func get_health() -> int:
	return health


func full_heal():
	update_health(max_health)


func update_health(new_health: int):
	if new_health > max_health:
		health = max_health
	else:
		health = new_health
	health_changed.emit(health)
	
	if new_health > 0:
		is_dead = false
	
	if new_health <= 0 and not is_dead:
		health_died.emit()
		is_dead = true
#	print(get_parent().name, " has new health: ", get_health(), "/", max_health)

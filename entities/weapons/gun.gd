extends Node3D
class_name Gun

@export var damage_per_shot: float = 50.0
@export var shot_cooldown_time: float = 1.0 # Time between each shot
@export var max_ammo: int = 5
@export var current_ammo: int = 5
@export var reload_time: float = 1.5

@onready var shot_cooldown_timer = $ShotCooldownTimer
@onready var reload_timer = $ReloadTimer


func _ready():
	shot_cooldown_timer.wait_time = shot_cooldown_time
	reload_timer.wait_time = reload_time
	reload_timer.timeout.connect(on_reload_finished)


func shoot(aim_cast: RayCast3D):
	if shot_cooldown_timer.time_left > 0:
		print("Shot cooling down")
		return
	if reload_timer.time_left > 0:
		print("Still reloading")
		return
	if current_ammo <= 0:
		print("Out of ammo")
		return
	
	aim_cast.force_raycast_update()
	if aim_cast.is_colliding():
		var target = aim_cast.get_collider()
		print("Hit target: ", target)
		if target.has_node("HealthComponent"):
			var health: HealthComponent = target.get_node("HealthComponent")
			health.take_damage(damage_per_shot)
			print("Dealt ", damage_per_shot, " dmg to ", target, " who now has ", health.get_health(), " hp.")
	current_ammo -= 1
	shot_cooldown_timer.start()


func reload():
	if reload_timer.time_left > 0:
		print("Still reloading")
		return
	reload_timer.start()


func on_reload_finished():
	current_ammo = max_ammo

extends Area3D

## An area that hurts anything that has HealthComponent when they enter

@export var damage: int = 0

func _ready():
	body_entered.connect(on_body_entered)


func on_body_entered(body: Node3D):
	if body.has_node("HealthComponent"):
		var health_component: HealthComponent = body.get_node("HealthComponent")
		health_component.take_damage(damage)


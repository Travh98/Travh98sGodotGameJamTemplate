extends Node3D
class_name RandomSfxPlayer

var sounds = []
@export var pitch_variance: float = 0.05

func _ready():
	for child in get_children():
		if child is AudioStreamPlayer3D:
			sounds.append(child)


func play_sound():
	if sounds.size() > 0:
		var sfx: AudioStreamPlayer3D = sounds[randi() % sounds.size()]
		if sfx:
			# Add positive or negative pitch
			if randi_range(0, 1) == 1:
				sfx.pitch_scale = 1.0 + pitch_variance * randf()
			else:
				sfx.pitch_scale = 1.0 - pitch_variance * randf()
			
			sfx.play()

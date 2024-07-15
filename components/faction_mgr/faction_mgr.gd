extends Node

enum Factions
{
	UNSET,
	RED,
	BLUE,
	UNDEAD,
}

func get_hostile_factions(my_faction: Factions):
	var hostile_array = []
	
	match my_faction:
		Factions.UNSET:
			pass
		Factions.RED:
			hostile_array.append(Factions.BLUE)
		Factions.BLUE:
			hostile_array.append(Factions.RED)
		Factions.UNDEAD:
			pass
	
	return hostile_array

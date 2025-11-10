extends Resource
class_name LootTable

@export var drops: Array[Drop] = []

func get_loot() -> Array[PackedScene]:
	var loot: Array[PackedScene] = []
	for d in drops:
		if d.guaranteed or randf() <= d.chance:
			loot.append(d.scene)
	return loot

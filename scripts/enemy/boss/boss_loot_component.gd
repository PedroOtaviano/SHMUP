extends Node
class_name BossLootComponent

var boss

func init(boss_ref):
	boss = boss_ref

func drop_loot():
	if boss.loot_table == null:
		return

	var loot_scenes = boss.loot_table.get_loot()
	for scene in loot_scenes:
		if scene == null:
			continue

		var loot = scene.instantiate()
		# leve deslocamento aleatório para espalhar os drops
		loot.global_position = boss.global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		boss.get_parent().add_child(loot)

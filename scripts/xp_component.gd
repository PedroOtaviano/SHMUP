extends Node
class_name XpComponent

@export var level: int = 1
@export var xp: int = 0
@export var xp_to_next: int = 100   # XP necessário para próximo nível
@export var xp_growth: float = 1.2  # multiplicador de crescimento

signal stats_changed
signal leveled_up(new_level: int)

func add_xp(amount: int):
	xp += amount
	if xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		xp_to_next = int(xp_to_next * xp_growth)
		emit_signal("leveled_up", level)
	emit_signal("stats_changed")

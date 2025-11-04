extends Control

@onready var lv_label = $HBoxContainer/VBoxContainer/LvLabel
@onready var hp_bar = $HBoxContainer/VBoxContainer/HPBar
@onready var xp_bar = $HBoxContainer/VBoxContainer/XPBar

var player

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if player:
		update_all()
		# conecta sinais do player para atualizar automaticamente
		player.connect("stats_changed", Callable(self, "update_all"))

func update_all():
	if not player:
		return
	lv_label.text = "LV" + str(player.level)
	xp_bar.max_value = player.xp_to_next
	xp_bar.value = player.xp
	hp_bar.max_value = player.max_health
	hp_bar.value = player.health

extends Control

@onready var materials = $TabContainer/Materials
@onready var upgrades = $TabContainer/Upgrades
@onready var support_units = $"TabContainer/Support Units"

@onready var tab_container = $TabContainer

var player: Player = null


func _process(delta):
	# ir para próxima aba
	if Input.is_action_just_pressed("ui_right"):
		var next = (tab_container.current_tab + 1) % tab_container.get_tab_count()
		tab_container.current_tab = next

	# ir para aba anterior
	if Input.is_action_just_pressed("ui_left"):
		var prev = (tab_container.current_tab - 1 + tab_container.get_tab_count()) % tab_container.get_tab_count()
		tab_container.current_tab = prev
		
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("inventory"):
		queue_free()
		get_tree().paused = false

func _ready():
	
	var nodes = get_tree().get_nodes_in_group("player")
	if nodes.size() > 0:
		player = nodes[0]
		# força o Player a ter a unidade
		player.support_units.append("Support Drone Mk1")
		update_inventory()

func update_inventory():
	if not player:
		return
		
	materials.clear()
	for name in player.materials.keys():
		materials.add_item("%s x%d" %[name, player.materials[name]])
	
	upgrades.clear()
	for up in player.upgrades:
		upgrades.add_item(up)
		
	support_units.clear()
	for su in player.support_units:
		support_units.add_item(su)

# -------------------------
# Seleção de Support Unit
# -------------------------

func _on_support_units_item_selected(index):
	var support_name = support_units.get_item_text(index)
	print("Support Unit selecionada:", support_name)

	var unit_scene = preload("res://scenes/Support Units/sumk_1.tscn")

	# Support Unit à esquerda
	var left_unit = unit_scene.instantiate()
	left_unit.bullet_scene = preload("res://scenes/Player/Bullets/bullet.tscn")
	left_unit.move_offset = Vector2(-60, -20)
	left_unit.global_position = player.global_position + left_unit.move_offset
	player.get_parent().add_child(left_unit)

	# Support Unit à direita
	var right_unit = unit_scene.instantiate()
	right_unit.bullet_scene = preload("res://scenes/Player/Bullets/bullet.tscn")
	right_unit.move_offset = Vector2(60, -20)
	right_unit.global_position = player.global_position + right_unit.move_offset
	player.get_parent().add_child(right_unit)

	print("Support Units equipadas: esquerda e direita")

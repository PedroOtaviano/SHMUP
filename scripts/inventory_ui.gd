extends Control

@onready var materials = $TabContainer/Materials
@onready var upgrades = $TabContainer/Upgrades
@onready var support_units = $"TabContainer/Support Units"

@onready var tab_container = $TabContainer

var player: Player = null
var inventory_component: InventoryComponent = null

func _ready():
	# pega o Player pelo grupo
	var nodes = get_tree().get_nodes_in_group("player")
	if nodes.size() > 0:
		player = nodes[0]
		inventory_component = player.get_node_or_null("InventoryComponent")

	if inventory_component:
		inventory_component.item_added.connect(_on_item_added)
		inventory_component.upgrade_added.connect(_on_upgrade_added)
		inventory_component.support_unit_added.connect(_on_support_unit_added)
		inventory_component.inventory_opened.connect(update_inventory)

	update_inventory()

func _process(delta):
	# navegação entre abas
	if Input.is_action_just_pressed("ui_right"):
		var next = (tab_container.current_tab + 1) % tab_container.get_tab_count()
		tab_container.current_tab = next

	if Input.is_action_just_pressed("ui_left"):
		var prev = (tab_container.current_tab - 1 + tab_container.get_tab_count()) % tab_container.get_tab_count()
		tab_container.current_tab = prev

	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("inventory"):
		queue_free()
		get_tree().paused = false

# -------------------------
# Atualização da UI
# -------------------------
func update_inventory():
	if not inventory_component:
		return

	materials.clear()
	for name in inventory_component.items:
		materials.add_item(name)

	upgrades.clear()
	for up in inventory_component.upgrades:
		upgrades.add_item(up)

	support_units.clear()
	for su in inventory_component.support_units:
		support_units.add_item(su)

# -------------------------
# Reações a sinais
# -------------------------
func _on_item_added(item_name: String):
	materials.add_item(item_name)

func _on_upgrade_added(upgrade_name: String):
	upgrades.add_item(upgrade_name)

func _on_support_unit_added(unit_name: String):
	support_units.add_item(unit_name)

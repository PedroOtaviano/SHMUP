extends Node
class_name InventoryComponent

signal item_added(item_name: String)
signal upgrade_added(upgrade_name: String)
signal support_unit_added(unit_name: String)
signal inventory_opened
signal inventory_closed

var items: Array[String] = []
var upgrades: Array[String] = []
var support_units: Array[String] = []
var is_open: bool = false

func add_item(item_name: String):
	items.append(item_name)
	emit_signal("item_added", item_name)
	emit_signal("inventory_opened") # força atualização

func add_upgrade(upgrade_name: String):
	upgrades.append(upgrade_name)
	emit_signal("upgrade_added", upgrade_name)
	emit_signal("inventory_opened")

func add_support_unit(unit_name: String):
	support_units.append(unit_name)
	emit_signal("support_unit_added", unit_name)
	emit_signal("inventory_opened")


func toggle_inventory():
	is_open = !is_open
	if is_open:
		emit_signal("inventory_opened")
	else:
		emit_signal("inventory_closed")

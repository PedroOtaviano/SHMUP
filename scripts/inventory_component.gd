extends Node
class_name InventoryComponent

var materials: Dictionary = {}
var upgrades: Array[String] = []
var support_units: Array[String] = []

signal support_unit_added(name: String)

func add_item(item_name: String):
	materials[item_name] = materials.get(item_name, 0) + 1

func add_upgrade(upgrade_name: String):
	upgrades.append(upgrade_name)

func add_support_unit(unit_name: String):
	support_units.append(unit_name)
	emit_signal("support_unit_added", unit_name)

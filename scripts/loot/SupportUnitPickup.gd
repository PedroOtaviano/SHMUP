extends PickupBase
class_name SupportUnitPickup

func apply_pickup(inventory: InventoryComponent) -> void:
	inventory.add_support_unit(pickup_name)

func _ready():
	super._ready()
	popup_color = Color(0.229, 0.367, 0.744, 1.0) # azul para diferenciar

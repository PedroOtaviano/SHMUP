extends PickupBase
class_name UpgradePickup

func apply_pickup(inventory: InventoryComponent) -> void:
	inventory.add_upgrade(pickup_name)

func _ready():
	super._ready()
	popup_color = Color(0.843, 0.643, 0.0, 1.0) # dourado/laranja

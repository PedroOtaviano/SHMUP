extends Resource
class_name InventoryItem

@export var item_name: String
@export var description: String
@export var icon: Texture2D
@export var item_type: String = "support" # pode ser "upgrade", "material", "support"
@export var scene: PackedScene # cena que será instanciada quando equipado

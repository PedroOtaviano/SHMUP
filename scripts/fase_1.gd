extends Node2D

var tutorial_manager
var inventory_ui_scene = preload("res://scenes/UI/inventory_ui.tscn")
@onready var ui_layer = $UI   # CanvasLayer da cena principal

func _ready():
	var tutorial_scene = preload("uid://cdqs6e3yjhphc")
	tutorial_manager = tutorial_scene.instantiate()
	add_child(tutorial_manager)

	tutorial_manager.show_tip("Use WASD ou setas para se mover")

func _process(delta):
	# abrir inventário com tecla
	if Input.is_action_just_pressed("inventory"):
		show_inventory()

func show_inventory():
	# evita abrir múltiplas vezes
	if ui_layer.has_node("InventoryUI"):
		return

	var inv_ui = inventory_ui_scene.instantiate()
	inv_ui.name = "InventoryUI"
	ui_layer.add_child(inv_ui)

	# pausa o jogo enquanto inventário está aberto
	get_tree().paused = true

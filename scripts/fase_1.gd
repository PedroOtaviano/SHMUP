extends Node2D

var tutorial_manager

func _ready():
	var tutorial_scene = preload("uid://cdqs6e3yjhphc")  # carrega a cena
	tutorial_manager = tutorial_scene.instantiate()      # instancia a cena
	add_child(tutorial_manager)                          # adiciona à árvore

	tutorial_manager.show_tip("Use WASD ou setas para se mover")

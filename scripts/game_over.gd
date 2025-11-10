extends Control

func _ready():
	# pausa o jogo inteiro
	get_tree().paused = true
	
	var viewport_size = get_viewport_rect().size
	$Panel.position = (viewport_size - $Panel.size) / 2

func _on_restart_pressed():
	# Reinicia a fase atual
	print("restart clicado")
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_back_to_mission_select_pressed():
	pass # Replace with function body.

extends Control

func _ready():
	# Aqui você pode colocar música de fundo ou inicialização de UI
	print("Menu Principal carregado")

func _process(delta):
	# Normalmente não precisa processar nada no menu
	pass

func _on_start_game_pressed():
	# Vai direto para a cena de seleção de missão
	get_tree().change_scene_to_file("res://scenes/Menus/mission_select.tscn")

func _on_options_pressed():
	# Placeholder: pode abrir uma cena de opções ou popup
	print("Opções ainda não implementadas")
	# Exemplo: get_tree().change_scene_to_file("res://ui/Options.tscn")

func _on_exit_game_pressed():
	# Fecha o jogo
	get_tree().quit()

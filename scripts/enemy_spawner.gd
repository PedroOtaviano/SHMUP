extends Node2D

# Export das cenas de inimigos
@export var enemy_1_scene: PackedScene
@export var enemy_kamikaze_scene: PackedScene
@export var enemy_sniper_scene: PackedScene
@export var enemy_tank_scene: PackedScene

@export var spawn_area_width: int = 400

# Definição das waves da fase
var waves = [
	# Início
	{"type": "line", "enemy": "enemy_1", "count": 5, "y": -100, "spacing": 60, "delay": 2.0},
	{"type": "random", "enemy": "enemy_1", "count": 6, "interval": 0.5, "delay": 3.0},

	# Meio
	{"type": "v", "enemy": "enemy_kamikaze", "count": 4, "y": -100, "spacing": 70, "delay": 3.0},
	{"type": "line", "enemy": "enemy_sniper", "count": 3, "y": -120, "spacing": 100, "delay": 2.0},
	{"type": "random", "enemy": "enemy_kamikaze", "count": 3, "interval": 0.7, "delay": 3.0},

	# Clímax
	{"type": "diagonal", "enemy": "enemy_tank", "count": 2, "y": -150, "spacing": 120, "delay": 4.0},
	{"type": "random", "enemy": "enemy_1", "count": 8, "interval": 0.3, "delay": 2.0},
	{"type": "line", "enemy": "enemy_sniper", "count": 3, "y": -100, "spacing": 120, "delay": 2.0},
	{"type": "v", "enemy": "enemy_kamikaze", "count": 5, "y": -100, "spacing": 60, "delay": 4.0},

	# Boss
	{"type": "boss", "delay": 5.0}
]

# -----------------------
# Funções públicas
# -----------------------

# Dispara uma wave específica (usado pelos triggers)
func spawn_wave_by_index(index: int) -> void:
	if index < 0 or index >= waves.size():
		push_warning("Wave inválida: " + str(index))
		return
	var wave = waves[index]
	await spawn_wave(wave)

# -----------------------
# Funções internas
# -----------------------

func spawn_wave(wave: Dictionary) -> void:
	var viewport_size = get_viewport_rect().size
	var margin := 32.0
	var base_x = randf_range(margin, viewport_size.x - margin)

	# zona de segurança: evita spawn em cima do jogador
	var player = get_tree().get_first_node_in_group("player")
	if player:
		while abs(base_x - player.position.x) < 100:
			base_x = randf_range(margin, viewport_size.x - margin)

	match wave["type"]:
		"random":
			for i in range(wave["count"]):
				spawn_enemy(wave["enemy"])
				await get_tree().create_timer(wave.get("interval", 0.5)).timeout

		"line":
			spawn_line(wave["enemy"], wave["count"], wave["y"], wave.get("spacing", 50), base_x)

		"v":
			spawn_v(wave["enemy"], wave["count"], wave["y"], wave.get("spacing", 50), base_x)

		"diagonal":
			spawn_diagonal(wave["enemy"], wave["count"], base_x, wave["y"], wave.get("spacing", 50))

		"boss":
			spawn_boss()

	# delay antes da próxima ação (se quiser encadear waves)
	await get_tree().create_timer(wave.get("delay", 2.0)).timeout

# -----------------------
# Funções de spawn
# -----------------------

func get_enemy_scene(enemy_name: String) -> PackedScene:
	match enemy_name:
		"enemy_1":
			return enemy_1_scene
		"enemy_kamikaze":
			return enemy_kamikaze_scene
		"enemy_sniper":
			return enemy_sniper_scene
		"enemy_tank":
			return enemy_tank_scene
		_:
			return null

func spawn_enemy(enemy_name: String):
	var scene = get_enemy_scene(enemy_name)
	if scene == null:
		push_warning("Cena de inimigo não atribuída: " + enemy_name)
		return

	var enemy = scene.instantiate()
	var viewport_size = get_viewport_rect().size
	var margin := 32.0
	var random_x = randf_range(margin, viewport_size.x - margin)

	enemy.position = Vector2(random_x, -100)
	add_child(enemy)

func spawn_line(enemy_name: String, count: int, y: float, spacing: float = 50.0, base_x: float = 100.0):
	var scene = get_enemy_scene(enemy_name)
	if scene == null:
		return

	var viewport_size = get_viewport_rect().size
	var margin := 32.0
	var total_width = (count - 1) * spacing
	var clamped_x = clamp(base_x, margin, viewport_size.x - margin - total_width)

	for i in range(count):
		var enemy = scene.instantiate()
		enemy.position = Vector2(clamped_x + i * spacing, y)
		add_child(enemy)

func spawn_v(enemy_name: String, count: int, y: float, spacing: float = 50.0, base_x: float = 200.0):
	var scene = get_enemy_scene(enemy_name)
	if scene == null:
		return

	var viewport_size = get_viewport_rect().size
	var margin := 32.0
	var max_offset = (count / 2) * spacing
	var clamped_x = clamp(base_x, margin + max_offset, viewport_size.x - margin - max_offset)

	for i in range(count):
		var offset = (i - count/2) * spacing
		var enemy = scene.instantiate()
		enemy.position = Vector2(clamped_x + offset, y + abs(offset) * 0.5)
		add_child(enemy)

func spawn_diagonal(enemy_name: String, count: int, start_x: float, start_y: float, spacing: float = 50.0):
	var scene = get_enemy_scene(enemy_name)
	if scene == null:
		return

	var viewport_size = get_viewport_rect().size
	var margin := 32.0
	var max_width = (count - 1) * spacing
	var clamped_x = clamp(start_x, margin, viewport_size.x - margin - max_width)

	for i in range(count):
		var enemy = scene.instantiate()
		enemy.position = Vector2(clamped_x + i * spacing, start_y + i * spacing)
		add_child(enemy)

func spawn_boss():
	var boss_scene = load("res://scenes/Enemies/boss.tscn")
	var boss = boss_scene.instantiate()
	var viewport_size = get_viewport_rect().size
	boss.position = Vector2(viewport_size.x / 2, -200)  # entra de cima
	add_child(boss)

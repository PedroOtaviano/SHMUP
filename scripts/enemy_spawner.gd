extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_area_width: int = 400

# Waves híbridas: random, line, v, diagonal
var waves = [
	{"type": "random", "count": 5, "interval": 0.5, "delay": 2.0},
	{"type": "line", "count": 6, "y": -100, "spacing": 60, "delay": 3.0},
	{"type": "v", "count": 7, "y": -100, "spacing": 50, "delay": 3.0},
	{"type": "diagonal", "count": 5, "y": -100, "spacing": 60, "delay": 3.0},
	{"type": "random", "count": 8, "interval": 0.3, "delay": 4.0},
	{"type": "boss", "delay": 5.0}
]

var current_wave := 0

func _ready():
	start_next_wave()

func start_next_wave():
	if current_wave >= waves.size():
		print("Todas as ondas terminaram!")
		return

	var wave = waves[current_wave]
	spawn_wave(wave)

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
				spawn_enemy()
				await get_tree().create_timer(wave.get("interval", 0.5)).timeout

		"line":
			spawn_line(wave["count"], wave["y"], wave.get("spacing", 50), base_x)

		"v":
			spawn_v(wave["count"], wave["y"], wave.get("spacing", 50), base_x)

		"diagonal":
			spawn_diagonal(wave["count"], base_x, wave["y"], wave.get("spacing", 50))
		"boss":
			spawn_boss()


	await get_tree().create_timer(wave.get("delay", 2.0)).timeout
	current_wave += 1
	start_next_wave()

# -----------------------
# Funções de spawn
# -----------------------

func spawn_enemy():
	if enemy_scene == null:
		push_warning("Enemy scene não atribuída no editor!")
		return

	var enemy = enemy_scene.instantiate()
	var viewport_size = get_viewport_rect().size
	var margin := 32.0
	var random_x = randf_range(margin, viewport_size.x - margin)

	# spawn sempre fora da tela
	enemy.position = Vector2(random_x, -100)
	add_child(enemy)

func spawn_line(count: int, y: float, spacing: float = 50.0, base_x: float = 100.0):
	var viewport_size = get_viewport_rect().size
	var margin := 32.0
	var total_width = (count - 1) * spacing
	var clamped_x = clamp(base_x, margin, viewport_size.x - margin - total_width)

	for i in range(count):
		var enemy = enemy_scene.instantiate()
		enemy.position = Vector2(clamped_x + i * spacing, y)
		add_child(enemy)

func spawn_v(count: int, y: float, spacing: float = 50.0, base_x: float = 200.0):
	var viewport_size = get_viewport_rect().size
	var margin := 32.0
	var max_offset = (count / 2) * spacing
	var clamped_x = clamp(base_x, margin + max_offset, viewport_size.x - margin - max_offset)

	for i in range(count):
		var offset = (i - count/2) * spacing
		var enemy = enemy_scene.instantiate()
		enemy.position = Vector2(clamped_x + offset, y + abs(offset) * 0.5)
		add_child(enemy)

func spawn_diagonal(count: int, start_x: float, start_y: float, spacing: float = 50.0):
	var viewport_size = get_viewport_rect().size
	var margin := 32.0
	# garante que a diagonal não saia da tela
	var max_width = (count - 1) * spacing
	var clamped_x = clamp(start_x, margin, viewport_size.x - margin - max_width)

	for i in range(count):
		var enemy = enemy_scene.instantiate()
		enemy.position = Vector2(clamped_x + i * spacing, start_y + i * spacing)
		add_child(enemy)
		
func spawn_boss():
	if enemy_scene == null:
		push_warning("Boss scene não atribuída no editor!")
		return

	var boss_scene = load("res://scenes/boss.tscn")
	var boss = boss_scene.instantiate()

	var viewport_size = get_viewport_rect().size
	boss.position = Vector2(viewport_size.x / 2, -200)  # entra de cima
	add_child(boss)

extends Area2D

var slow_multiplier = 0.4  # 40% da velocidade normal

# -------------------------
# Atributos base
# -------------------------
@export var base_speed: float = 300.0
@export var base_health: int = 10
@export var base_attack: float = 1.0

@export var screen_size: Vector2
@export var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")

# -------------------------
# Player Hud
# -------------------------

@onready var hud = get_tree().get_first_node_in_group("player_hud")
signal stats_changed

# -------------------------
# Progressão
# -------------------------
var level: int = 1
var max_level: int = 30
var xp: int = 0
var xp_to_next: int = 100

# Status atuais (calculados dinamicamente)
var health: int
var max_health: int
var speed: float
var attack: float

# -------------------------
# Controle de tiro automático
# -------------------------
@export var fire_rate: float = 0.15   # tempo entre disparos (em segundos)
var shoot_cooldown: float = 0.0

# -------------------------
# Equipamentos
# -------------------------
var current_ship: String = "Nave Básica"
var current_modules: Array = []

# -------------------------
# Inicialização
# -------------------------
func _ready():
	recalc_stats()
	health = max_health
	screen_size = get_viewport_rect().size
# -------------------------
# Loop de jogo
# -------------------------
func _process(delta):
	# Atualiza cooldown
	if shoot_cooldown > 0:
		shoot_cooldown -= delta

	# Se o botão estiver pressionado e o cooldown zerado, dispara
	if Input.is_action_pressed("shoot") and shoot_cooldown <= 0.0:
		shoot()
		shoot_cooldown = fire_rate

func _physics_process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()

	# Velocidade base
	var current_speed = speed

	# Se estiver segurando a tecla de precisão, reduz a velocidade
	if Input.is_action_pressed("slow"):
		current_speed *= 0.4   # 40% da velocidade normal (ajuste como quiser)

	# Aplica movimento
	position += direction * current_speed * delta

	# Limita a nave dentro da tela
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

# -------------------------
# Tiro
# -------------------------
func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.position = position + Vector2(0, -20)
	
	# passa o ataque atual do player para a bala
	bullet.power = attack  
	
	get_parent().add_child(bullet)


# -------------------------
# Progressão de XP e Nível
# -------------------------
func add_xp(amount: int):
	xp += amount
	if xp >= xp_to_next and level < max_level:
		level_up()
	emit_signal("stats_changed")

func level_up():
	level += 1
	xp -= xp_to_next
	xp_to_next = int(xp_to_next * 1.2) # curva de XP crescente
	recalc_stats()
	print("Level UP! Agora nível %d" % level)
	emit_signal("stats_changed")

func recalc_stats():
	# Fórmulas de progressão suave
	max_health = int(base_health * (1.0 + 0.04 * (level - 1))) # +80% até Lv30
	speed = base_speed * (1.0 + 0.015 * (level - 1))           # +30% até Lv30
	attack = base_attack * (1.0 + 0.025 * (level - 1))         # +50% até Lv30

# -------------------------
# Equipamentos com requisito de nível
# -------------------------
func can_equip(equipment: Dictionary) -> bool:
	# equipment = { "name": "Laser Avançado", "min_level": 10 }
	return level >= equipment.get("min_level", 1)

func equip_ship(ship_data: Dictionary):
	if can_equip(ship_data):
		current_ship = ship_data["name"]
		print("Nave equipada: %s" % current_ship)
	else:
		print("Nível insuficiente para equipar %s (requer Lv%d)" %
			[ship_data["name"], ship_data["min_level"]])

func equip_module(module_data: Dictionary):
	if can_equip(module_data):
		current_modules.append(module_data["name"])
		print("Módulo equipado: %s" % module_data["name"])
	else:
		print("Nível insuficiente para equipar %s (requer Lv%d)" %
			[module_data["name"], module_data["min_level"]])

# -------------------------
# Dano e morte
# -------------------------
func _on_area_entered(area):
	if area.is_in_group("enemy_bullet"):
		take_damage(area.damage)
		area.queue_free()

func take_damage(amount: int):
	health -= amount
	print("Player levou dano! Vida restante: %d" % health)
	if health <= 0:
		die()
	emit_signal("stats_changed")

func die():
	print("Player morreu!")
	queue_free()

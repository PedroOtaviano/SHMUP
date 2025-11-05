extends Resource
class_name PlayerStats

# -------------------------
# Atributos base
# -------------------------
@export var base_speed: float = 300.0
@export var base_health: int = 10
@export var base_attack: float = 1.0
@export var base_shield: int = 5                # escudo inicial
@export var shield_regen_rate: float = 1.0      # pontos por segundo
@export var shield_regen_delay: float = 10.0     # segundos sem dano para começar a regenerar

# -------------------------
# Progressão
# -------------------------
@export var level: int = 1
@export var max_level: int = 30
@export var xp: int = 0
@export var xp_to_next: int = 100

# -------------------------
# Status atuais (calculados dinamicamente)
# -------------------------
var max_health: int
var speed: float
var attack: float
var max_shield: int

# -------------------------
# Inicialização
# -------------------------
func _init():
	recalc_stats()

# -------------------------
# Métodos de progressão
# -------------------------
func add_xp(amount: int) -> bool:
	xp += amount
	if xp >= xp_to_next and level < max_level:
		level_up()
		return true
	return false

func level_up():
	level += 1
	xp -= xp_to_next
	xp_to_next = int(xp_to_next * 1.5) # curva de XP crescente
	recalc_stats()

func recalc_stats():
	# Fórmulas de progressão suave
	max_health = int(base_health * (1.0 + 0.04 * (level - 1))) # +80% até Lv30
	speed = base_speed * (1.0 + 0.015 * (level - 1))           # +30% até Lv30
	attack = base_attack * (1.0 + 0.025 * (level - 1))         # +50% até Lv30
	max_shield = int(base_shield * (1.0 + 0.03 * (level - 1))) # +90% até Lv30

extends Enemy
class_name EnemyTank

@export var move_speed: float = 60.0   # lento
@export var damage: int = 4            # dano alto no contato
@export var attack_cooldown: float = 1.5

var attack_timer: float = 0.0

func _ready():
	super._ready()
	max_health = 15
	health = max_health

func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# anda lentamente em direção ao player
	var dir = (player.global_position - global_position).normalized()
	position += dir * move_speed * delta

	if attack_timer > 0:
		attack_timer -= delta

# -------------------------
# Balas do Player
# -------------------------
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullet"):
		take_damage(area.power)
		area.queue_free()

# -------------------------
# Contato direto com Player
# -------------------------
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and attack_timer <= 0:
		var health_component = body.get_node_or_null("HealthComponent")
		if health_component:
			health_component.take_damage(damage)
		attack_timer = attack_cooldown

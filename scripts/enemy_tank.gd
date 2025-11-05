extends Enemy

@export var move_speed: float = 60.0   # lento
@export var damage: int = 4            # dano alto no contato
@export var attack_cooldown: float = 1.5

var attack_timer: float = 0.0

func _ready():
	super._ready()
	max_health = 15
	health = max_health

func _physics_process(delta: float) -> void:
	# procura o player pelo grupo
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# anda lentamente em direção ao player
	var dir = (player.global_position - global_position).normalized()
	position += dir * move_speed * delta

	if attack_timer > 0:
		attack_timer -= delta

func _on_area_entered(area: Area2D) -> void:
	# dano de balas
	if area.is_in_group("player_bullet"):
		take_damage(area.power)
		area.queue_free()
	# dano no player por contato
	elif area.is_in_group("player") and attack_timer <= 0 and area.has_method("take_damage"):
		area.take_damage(damage)
		attack_timer = attack_cooldown

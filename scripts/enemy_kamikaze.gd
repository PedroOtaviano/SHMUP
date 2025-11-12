extends Enemy
class_name EnemyKamikaze

@export var kamikaze_speed: float = 200.0
@export var contact_damage: int = 1   # dano ao encostar no player

@onready var player = get_tree().get_first_node_in_group("player")
@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	max_health = 1
	# Conectar sinal body_entered para detectar Player
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		body_entered.connect(_on_body_entered)

func move_pattern(delta: float) -> void:
	if player:
		var dir = (player.global_position - global_position).normalized()
		position += dir * kamikaze_speed * delta

# Detecta balas do Player (ainda são Area2D)
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullet"):
		take_damage(area.power)
		area.queue_free()

# Detecta contato direto com Player (CharacterBody2D)
func _on_body_entered(body: Node) -> void:
	
	if body.is_in_group("player"):
		var health_component = body.get_node_or_null("HealthComponent")
		if health_component:
			health_component.take_damage(contact_damage)
		explode()   # kamikaze morre ao encostar

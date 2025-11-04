extends Enemy

@export var kamikaze_speed: float = 200.0
@onready var player = get_tree().get_first_node_in_group("player")
@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	max_health = 1

func move_pattern(delta: float) -> void:
	if player:
		var dir = (player.global_position - global_position).normalized()
		position += dir * kamikaze_speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		if area.has_method("take_damage"):
			area.take_damage(1) # dano ao player
		explode()
	elif area.is_in_group("player_bullet"):
		take_damage(area.power)
		area.queue_free()

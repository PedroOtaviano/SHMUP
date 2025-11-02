extends Area2D

@export var max_health: int = 150
var health: int

@export var bullet_scene: PackedScene = preload("res://scenes/enemy_bullet.tscn")
@export var fire_rate: float = 1.0
@onready var animated_sprite_2d = $AnimatedSprite2D

var center_x: float
var time_passed: float = 0.0

var original_color: Color

func _ready():
	health = max_health
	original_color = animated_sprite_2d.self_modulate
	center_x = position.x

func _physics_process(delta):
	if position.y < 100:
		position.y += 50 * delta
	else:
		time_passed += delta
		# Oscila em torno do centro, indo para esquerda e direita
		position.x = center_x + sin(time_passed) * 150

func _process(delta):
	if randi() % int(60 / fire_rate) == 0:
		shoot()

func shoot():
	if bullet_scene == null:
		return
	# Primeiro leque (para baixo à esquerda)
	for angle in range(45, 91, 15):  # de 45° até 90° (diagonal esq-baixo até baixo)
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.position = global_position
		bullet.direction = Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle)))

	# Segundo leque (para baixo à direita)
	for angle in range(90, 136, 15):  # de 90° até 135° (baixo até diagonal dir-baixo)
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.position = global_position
		bullet.direction = Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle)))

func take_damage(amount: int) -> void:
	health -= amount
	flash_effect()
	print("Boss Levou dano!")
	if health <= 0:
		die()

func flash_effect():
	if animated_sprite_2d.has_meta("flash_tween"):
		var old_tween: Tween = animated_sprite_2d.get_meta("flash_tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()
	var tween = create_tween()
	animated_sprite_2d.set_meta("flash_tween", tween)
	animated_sprite_2d.self_modulate = Color(1, 0.2, 0.2)
	tween.tween_property(animated_sprite_2d, "self_modulate", original_color, 0.15) \
		 .set_trans(Tween.TRANS_LINEAR) \
		 .set_ease(Tween.EASE_IN_OUT)


func die():
	queue_free()
	print("Boss derrotado!")


func _on_area_entered(area):
	if area.is_in_group("player_bullet"):
		take_damage(area.power)
		area.queue_free()

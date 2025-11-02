extends Area2D

@export var speed: int = 300
@export var screen_size: Vector2
@export var max_health: int = 10

var health: int

@export var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")

func _ready():
	health = max_health
	screen_size = get_viewport_rect().size

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		shoot()

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

	position += direction.normalized() * speed * delta

	# Limita a nave dentro da tela
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.position = position + Vector2(0, -20) # nasce um pouco acima da nave
	get_parent().add_child(bullet)

func _on_area_entered(area):
	if area.is_in_group("enemy_bullet"):
		take_damage(area.damage)
		area.queue_free()

func take_damage(amount: int):
	health -= amount
	print("Player levou dano! Vida restante: %d" % health)
	if health <= 0:
		die()

func die():
	print("Player morreu!")
	queue_free()

extends Area2D

@export var speed: int = 100
@export var max_health: int = 3
var health: int

@export var bullet_scene: PackedScene
@export var fire_rate: float = 1.5
@onready var player = get_tree().get_first_node_in_group("player")

@export var amplitude: float = 60.0   # largura da curva (quanto se move para os lados)
@export var frequency: float = 2.0    # rapidez da oscilação
var time_passed: float = 0.0
var start_x: float

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
var original_color: Color

func _ready():
	health = max_health
	original_color = anim_sprite.self_modulate
	start_x = position.x
	start_shooting()
	
func start_shooting():
	shoot()
	var timer = Timer.new()
	timer.wait_time = fire_rate
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(shoot)
	
func shoot():
	if player == null:
		return
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.position = global_position

	var dir = (player.global_position - global_position).normalized()
	bullet.direction = dir

func _physics_process(delta):
	time_passed += delta
	position.y += speed * delta
	position.x = start_x + sin(time_passed * frequency) * amplitude
	
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullet"):
		take_damage(area.power)
		area.queue_free()

func take_damage(amount: int) -> void:
	health -= amount
	flash_effect()
	print("Levou dano!")
	if health <= 0:
		die()

func flash_effect():
	# Se já existir um tween rodando, mata ele antes de criar outro
	if anim_sprite.has_meta("flash_tween"):
		var old_tween: Tween = anim_sprite.get_meta("flash_tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	# Cria um novo tween
	var tween = create_tween()
	anim_sprite.set_meta("flash_tween", tween)

	anim_sprite.self_modulate = Color(1, 0.2, 0.2)

	tween.tween_property(anim_sprite, "self_modulate", original_color, 0.15) \
		 .set_trans(Tween.TRANS_LINEAR) \
		 .set_ease(Tween.EASE_IN_OUT)

# func flash_effect():

#	anim_sprite.self_modulate = Color(1, 0.2, 0.2)
#	await get_tree().create_timer(0.15).timeout
#	anim_sprite.self_modulate = original_color

func die() -> void:
	queue_free()

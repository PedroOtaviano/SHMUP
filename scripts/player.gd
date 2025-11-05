extends Area2D
class_name Player

# -------------------------
# Referências externas
# -------------------------
var stats = preload("uid://b1wjfxnmpc7ih")
@export var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
@export var fire_rate: float = 0.15         # tempo entre disparos
@export var screen_size: Vector2

@onready var hud = get_tree().get_first_node_in_group("player_hud")
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shield_sprite = $AnimatedSprite2D/Escudo

signal stats_changed

# -------------------------
# Variáveis internas
# -------------------------
var health: int
var shield: float
var shield_regen_timer: float = 0.0

var shoot_cooldown: float = 0.0
@export var invuln_time: float = 1.5   # tempo de invulnerabilidade em segundos
var is_invulnerable: bool = false

# -------------------------
# Inicialização
# -------------------------
func _ready():
	health = stats.max_health
	shield = stats.max_shield
	screen_size = get_viewport_rect().size
	update_shield_visual()
	emit_signal("stats_changed")

# -------------------------
# Loop de jogo
# -------------------------
func _process(delta):
	if shoot_cooldown > 0:
		shoot_cooldown -= delta

	if Input.is_action_pressed("shoot") and shoot_cooldown <= 0.0:
		shoot()
		shoot_cooldown = fire_rate

	# regeneração do escudo
	if shield < stats.max_shield:
		if shield_regen_timer > 0:
			shield_regen_timer -= delta
		else:
			shield += stats.shield_regen_rate * delta
			shield = clamp(shield, 0, stats.max_shield)
			update_shield_visual()

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

	var current_speed = stats.speed

	if Input.is_action_pressed("slow"):
		current_speed *= 0.4   # modo precisão

	position += direction * current_speed * delta

	# Limita dentro da tela
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

# -------------------------
# Tiro
# -------------------------
func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.position = position + Vector2(0, -20)
	bullet.power = stats.attack
	get_parent().add_child(bullet)

# -------------------------
# Progressão
# -------------------------
func add_xp(amount: int):
	if stats.add_xp(amount):
		# se subiu de nível
		health = stats.max_health
		shield = stats.max_shield
		print("Level UP! Agora nível %d" % stats.level)
	emit_signal("stats_changed")

# -------------------------
# Dano e morte
# -------------------------
func _on_area_entered(area: Area2D):
	if area.is_in_group("enemy_bullet"):
		take_damage(area.damage)
		area.queue_free()

func take_damage(amount: int):
	if is_invulnerable:
		return

	if shield > 0:
		shield -= amount
		if shield < 0:
			health += shield
			shield = 0
		shield_regen_timer = stats.shield_regen_delay
		if hud: hud.flash_shield_bar()
	else:
		health -= amount
		if hud: hud.flash_hp_bar()
		if health <= 0:
			die()
		else:
			start_invulnerability()

	update_shield_visual()
	emit_signal("stats_changed")

	update_shield_visual()
	emit_signal("stats_changed")

func start_invulnerability():
	is_invulnerable = true

	# efeito visual: piscar sprite do player
	var tween = create_tween()
	tween.set_loops(int(invuln_time / 0.2))
	tween.tween_property(animated_sprite_2d, "modulate:a", 0.2, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(animated_sprite_2d, "modulate:a", 1.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await get_tree().create_timer(invuln_time).timeout
	is_invulnerable = false
	animated_sprite_2d.modulate.a = 1.0

func die():
	print("Player morreu!")
	queue_free()

# -------------------------
# Escudo visual
# -------------------------
func update_shield_visual():
	shield_sprite.visible = shield > 0

func flash_shield():
	if not shield_sprite.visible:
		return
	shield_sprite.play("hit")  # animação de impacto do escudo

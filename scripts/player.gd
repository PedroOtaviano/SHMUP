extends CharacterBody2D
class_name Player

# -------------------------
# Referências externas
# -------------------------
var stats = preload("uid://b1wjfxnmpc7ih")
@export var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
@export var fire_rate: float = 0.15
@export var screen_size: Vector2

@onready var hud = get_tree().get_first_node_in_group("player_hud")
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shield_sprite = $AnimatedSprite2D/Escudo
@onready var exhaust = $AnimatedSprite2D/Exhaust
@onready var exhaust_2 = $AnimatedSprite2D/Exhaust2
@onready var hitbox = $Hitbox   # pode ser um Area2D filho para triggers

signal stats_changed

# -------------------------
# Variáveis internas
# -------------------------
var health: int
var shield: float
var shield_regen_timer: float = 0.0

var shoot_cooldown: float = 0.0
@export var invuln_time: float = 1.5
var is_invulnerable: bool = false

# -------------------------
# Inventário
# -------------------------
var materials: Dictionary = {}   # Ex: {"Metal Fragment": 3}
var upgrades: Array[String] = [] # Ex: ["Spread Shot", "Laser Beam"]

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
		if animated_sprite_2d.animation != "right_turn":
			animated_sprite_2d.play("right_turn")
		animated_sprite_2d.flip_h = false
	elif Input.is_action_pressed("left"):
		direction.x -= 1
		if animated_sprite_2d.animation != "left_turn":
			animated_sprite_2d.play("left_turn")
		animated_sprite_2d.flip_h = true
	else:
		if animated_sprite_2d.animation != "idle":
			animated_sprite_2d.play("idle")

	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()

	var current_speed = stats.speed
	if Input.is_action_pressed("slow"):
		current_speed *= 0.4

	velocity = direction * current_speed
	move_and_slide()

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
		health = stats.max_health
		shield = stats.max_shield
		print("Level UP! Agora nível %d" % stats.level)
	emit_signal("stats_changed")

# -------------------------
# Inventário
# -------------------------
func add_item(item_name: String):
	materials[item_name] = materials.get(item_name, 0) + 1
	print("Coletou material:", item_name, "| Total:", materials[item_name])

func add_upgrade(upgrade_name: String):
	upgrades.append(upgrade_name)
	print("Coletou upgrade:", upgrade_name, "| Upgrades:", upgrades)

func get_material_count(item_name: String) -> int:
	return materials.get(item_name, 0)

func has_upgrade(upgrade_name: String) -> bool:
	return upgrade_name in upgrades

# -------------------------
# Dano e morte
# -------------------------
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

func start_invulnerability():
	is_invulnerable = true
	var tween = create_tween()
	tween.set_loops(int(invuln_time / 0.2))
	tween.tween_property(animated_sprite_2d, "modulate:a", 0.2, 0.1)
	tween.tween_property(animated_sprite_2d, "modulate:a", 1.0, 0.1)

	await get_tree().create_timer(invuln_time).timeout
	is_invulnerable = false
	animated_sprite_2d.modulate.a = 1.0

func die():
	print("Player morreu!")
	animated_sprite_2d.play("death")
	shield_sprite.visible = false
	exhaust.visible = false
	exhaust_2.visible = false
	hitbox.visible = false
	hitbox.disabled = true
	set_physics_process(false)

	await get_tree().create_timer(1.5).timeout

	var game_over_scene = preload("res://scenes/game_over.tscn")
	var game_over_ui = game_over_scene.instantiate()
	var ui_node = get_tree().current_scene.get_node("UI")
	ui_node.add_child(game_over_ui)

# -------------------------
# Escudo visual
# -------------------------
func update_shield_visual():
	shield_sprite.visible = shield > 0

func flash_shield():
	if not shield_sprite.visible:
		return
	shield_sprite.play("hit")

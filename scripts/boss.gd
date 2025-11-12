extends Area2D

@export var max_health: int = 110
var health: int

@export var bullet_scene: PackedScene = preload("res://scenes/Enemies/enemy_bullet.tscn")

@export var fire_rate: float = 1.0
@export var fire_rate_circular: float = 0.5
@export var bullets_per_circle: int = 36
@export var rotation_step: float = 10.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shoot_point_left = $shoot_point_left
@onready var shoot_point_right = $shoot_point_right
@onready var boss_health_bar = get_tree().get_first_node_in_group("boss_hud")
@onready var contact_damage : int = 10

# Partículas para transição de fase
@onready var phase_particles: GPUParticles2D = $PhaseParticles2D

# -------------------------
# Progressão
# -------------------------
@export var xp_reward: int = 50   # XP dado ao player ao derrotar o boss
@onready var player = get_tree().get_first_node_in_group("player")

# Loot
@export var loot_table: LootTable

# Damage Popup
@export var damage_popup_scene: PackedScene

var center_x: float
var time_passed: float = 0.0
var circular_timer: float = 0.0
var angle_offset: float = 0.0
var original_color: Color

# -------------------------
# Enum para fases do Boss
# -------------------------
enum BossPhase { PHASE_ONE, PHASE_TWO, PHASE_THREE }
var current_phase: BossPhase = BossPhase.PHASE_ONE

func get_phase() -> BossPhase:
	var percent = float(health) / float(max_health)
	if percent > 0.7:
		return BossPhase.PHASE_ONE
	elif percent > 0.3:
		return BossPhase.PHASE_TWO
	else:
		return BossPhase.PHASE_THREE

# -------------------------
# Ciclo de vida
# -------------------------
func _ready():
	health = max_health
	original_color = animated_sprite_2d.self_modulate
	center_x = position.x

	if boss_health_bar:
		boss_health_bar.visible = true
		boss_health_bar.set_max_health(max_health)

	# Inicializa fase
	current_phase = get_phase()
	apply_phase_effects(current_phase)

func _physics_process(delta):
	if position.y < 100:
		position.y += 50 * delta
	else:
		time_passed += delta
		circular_timer += delta
		position.x = center_x + sin(time_passed) * 150

		var phase = get_phase()
		if phase != current_phase:
			current_phase = phase
			apply_phase_effects(current_phase)

		# Disparo circular nas fases 2 e 3
		if phase >= BossPhase.PHASE_TWO and circular_timer >= fire_rate_circular:
			circular_timer = 0.0
			shoot_circle(shoot_point_left)
			shoot_circle(shoot_point_right)
			angle_offset += rotation_step

		# Fase 3 acelera disparo circular
		if phase == BossPhase.PHASE_THREE:
			fire_rate_circular = 0.3
		else:
			fire_rate_circular = 0.5

func _process(delta):
	var phase = get_phase()
	# Fase 1 e 2 usam leque
	if phase <= BossPhase.PHASE_TWO and randi() % int(60 / fire_rate) == 0:
		shoot_fan()

# -------------------------
# Efeitos visuais por fase
# -------------------------
func apply_phase_effects(phase: BossPhase):
	match phase:
		BossPhase.PHASE_ONE:
			animated_sprite_2d.self_modulate = Color(1, 1, 1) # cor normal
			if phase_particles:
				phase_particles.emitting = false

		BossPhase.PHASE_TWO:
			animated_sprite_2d.self_modulate = Color(1, 0.7, 0.7) # levemente avermelhado
			if phase_particles:
				phase_particles.emitting = true
				phase_particles.amount = 80

		BossPhase.PHASE_THREE:
			animated_sprite_2d.self_modulate = Color(0.441, 0.0, 0.05, 1.0) # vermelho intenso
			if phase_particles:
				phase_particles.emitting = true
				phase_particles.amount = 150

# -------------------------
# Padrões de tiro
# -------------------------
func shoot_fan():
	if bullet_scene == null:
		return
	# Primeiro leque (para baixo à esquerda)
	for angle in range(45, 91, 15):
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.position = global_position
		bullet.direction = Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle)))
	# Segundo leque (para baixo à direita)
	for angle in range(90, 136, 15):
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.position = global_position
		bullet.direction = Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle)))

func shoot_circle(marker: Marker2D):
	if bullet_scene == null:
		return
	var step = 360.0 / bullets_per_circle
	for i in range(bullets_per_circle):
		var angle = deg_to_rad(i * step + angle_offset)
		var bullet = bullet_scene.instantiate()
		bullet.global_position = marker.global_position
		bullet.direction = Vector2(cos(angle), sin(angle))
		get_parent().add_child(bullet)

# -------------------------
# Dano e efeitos
# -------------------------
func take_damage(amount: int) -> void:
	health -= amount
	flash_effect()
	show_damage_popup(amount)   # <- Mostra popup de dano
	if boss_health_bar:
		boss_health_bar.update_health(health)
	if health <= 0:
		die()

func show_damage_popup(amount: int):
	if damage_popup_scene:
		var popup = damage_popup_scene.instantiate()
		popup.text = str(amount)
		print("Popup criado no Boss")
		get_parent().add_child(popup)
		popup.global_position = global_position + Vector2(0, -40)

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
	if boss_health_bar:
		boss_health_bar.visible = false

	# Dá XP ao player
	if player and player.has_method("add_xp"):
		player.add_xp(xp_reward)
		print("Player ganhou %d XP pela vitória contra o Boss!" % xp_reward)
		
	if loot_table:
		var scenes = loot_table.get_loot()
		for scene in scenes:
			var item = scene.instantiate()
			item.global_position = global_position
			get_tree().current_scene.add_child(item)


	queue_free()
	print("Boss derrotado!")

func _on_area_entered(area):
	if area.is_in_group("player_bullet"):
		take_damage(area.power)
		area.queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		var health_component = body.get_node_or_null("HealthComponent")
		if health_component:
			health_component.take_damage(contact_damage)

extends Area2D
class_name Enemy

@export var speed: int = 100
@export var max_health: int = 2
@export var xp_reward: int = 2
@export var loot_table: LootTable   # <- loot table exportada

var health: int
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var damage_popup_scene: PackedScene
var original_color: Color

signal died(enemy: Enemy)

func _ready():
	health = max_health
	if anim_sprite:
		original_color = anim_sprite.self_modulate
	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		area_entered.connect(_on_area_entered)

func _physics_process(delta):
	move_pattern(delta)

# -------------------------
# Métodos virtuais
# -------------------------
func move_pattern(delta: float) -> void:
	position.y += speed * delta

func attack_pattern() -> void:
	pass

# -------------------------
# Dano e morte
# -------------------------
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullet"):
		take_damage(area.power)
		area.queue_free()

func take_damage(amount: int) -> void:
	health -= amount
	flash_effect()
	show_damage_popup(amount)
	if health <= 0:
		explode()

func show_damage_popup(amount: int):
	if damage_popup_scene:
		var popup = damage_popup_scene.instantiate()
		popup.text = str(amount)
		get_parent().add_child(popup)
		popup.global_position = global_position + Vector2(0, -20)

func flash_effect():
	if anim_sprite:
		if anim_sprite.has_meta("flash_tween"):
			var old_tween: Tween = anim_sprite.get_meta("flash_tween")
			if old_tween and old_tween.is_valid():
				old_tween.kill()
		var tween = create_tween()
		anim_sprite.set_meta("flash_tween", tween)
		anim_sprite.self_modulate = Color(1, 0.2, 0.2)
		tween.tween_property(anim_sprite, "self_modulate", original_color, 0.15)

# -------------------------
# Explosão e morte
# -------------------------
func explode():
	disable_hitbox()
	if anim_sprite:
		anim_sprite.play("explosion")
		anim_sprite.animation_finished.connect(_on_explosion_finished, CONNECT_ONE_SHOT)
	else:
		die()

func _on_explosion_finished():
	die()

func die() -> void:
	# XP para o player via grupo
	var xpcomponent = get_tree().get_first_node_in_group("xpcomponent")
	if xpcomponent and xpcomponent is XpComponent:
		xpcomponent.add_xp(xp_reward)

	# Loot
	if loot_table:
		var loots = loot_table.get_loot()
		for scene in loots:
			var item = scene.instantiate()
			get_parent().add_child(item)
			item.global_position = global_position

	emit_signal("died", self)
	queue_free()
	
func disable_hitbox():
	monitoring = false
	monitorable = false
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.disabled = true
	if is_connected("area_entered", Callable(self, "_on_area_entered")):
		disconnect("area_entered", Callable(self, "_on_area_entered"))

extends Node
class_name HealthComponent

@export var max_health: int = 100
@export var max_shield: int = 50
@export var shield_regen_rate: float = 2.0
@export var shield_regen_delay: float = 3.0
@export var invuln_time: float = 1.5

var current_health: int
var current_shield: float
var shield_regen_timer: float = 0.0
var is_invulnerable: bool = false

signal stats_changed
signal died
signal took_damage(amount: int)

@onready var sprite: AnimatedSprite2D = get_parent().get_node_or_null("AnimatedSprite2D")
@onready var shield_sprite: AnimatedSprite2D = sprite.get_node_or_null("Escudo")

func _ready():
	current_health = max_health
	current_shield = max_shield
	update_shield_visual()
	emit_signal("stats_changed")

func _process(delta):
	if current_shield < max_shield:
		if shield_regen_timer > 0:
			shield_regen_timer -= delta
		else:
			current_shield = min(max_shield, current_shield + shield_regen_rate * delta)
			update_shield_visual()
			emit_signal("stats_changed")

func take_damage(amount: int):
	if is_invulnerable:
		return

	if current_shield > 0:
		current_shield -= amount
		if current_shield < 0:
			current_health += current_shield
			current_shield = 0
		shield_regen_timer = shield_regen_delay
		emit_signal("took_damage", amount)
	else:
		current_health -= amount
		emit_signal("took_damage", amount)
		if current_health <= 0:
			die()
			return
		else:
			start_invulnerability()

	update_shield_visual()
	emit_signal("stats_changed")

func start_invulnerability():
	is_invulnerable = true
	if sprite:
		var tween = create_tween()
		tween.set_loops(int(invuln_time / 0.2))
		tween.tween_property(sprite, "modulate:a", 0.2, 0.1)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.1)

	await get_tree().create_timer(invuln_time).timeout
	is_invulnerable = false
	if sprite:
		sprite.modulate.a = 1.0

func die():
	if sprite:
		sprite.play("death")
	if shield_sprite:
		shield_sprite.visible = false
	emit_signal("died")

func update_shield_visual():
	if shield_sprite:
		shield_sprite.visible = current_shield > 0

func flash_shield():
	if shield_sprite and shield_sprite.visible:
		shield_sprite.play("hit")

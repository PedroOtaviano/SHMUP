extends Area2D

@export var speed: int = 150
@export var max_health: int = 5
var health: int
var original_color: Color

func _ready():
	health = max_health
	original_color = modulate

func _physics_process(delta):
	position.y += speed * delta

	if position.y > get_viewport_rect().size.y + 50:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("player_bullet"):
		take_damage(area.damage)
		area.queue_free()


func take_damage(amount: int) -> void:
	health -= amount
	flash_effect()
	if health <= 0:
		die()

func die() -> void:
	# Aqui você pode tocar explosão, adicionar pontuação, etc.
	queue_free()


func flash_effect():
	var tween = create_tween()
	modulate = Color(1, 1, 1) 
	tween.tween_property(self, "modulate", original_color, 0.3) # volta em 0.15s

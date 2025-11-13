extends Area2D
class_name EnemyBullet

@export var speed: int = 300
@export var damage: int = 5

var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if not get_viewport_rect().has_point(position):
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		var health_component = body.get_node_or_null("HealthComponent")
		if health_component:
			health_component.take_damage(damage)
		queue_free()  # destrói o projétil após acertar

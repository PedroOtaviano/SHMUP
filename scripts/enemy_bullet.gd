extends Area2D

@export var speed: int = 300
@export var damage: int = 1

var direction: Vector2 = Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta
	if not get_viewport_rect().has_point(position):
		queue_free()

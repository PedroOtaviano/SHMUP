extends Area2D

@export var speed: int = 600
@export var damage: int = 1

func _ready():
	add_to_group("player_bullet")

func _physics_process(delta):
	position.y -= speed * delta
	
	if position.y < -10:
		queue_free()

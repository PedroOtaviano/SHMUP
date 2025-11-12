extends Node
class_name WeaponComponent

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.2
var cooldown: float = 0.0

func _process(delta):
	if cooldown > 0:
		cooldown -= delta
	if Input.is_action_pressed("shoot") and cooldown <= 0:
		shoot()
		cooldown = fire_rate

func shoot():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = get_parent().global_position + Vector2(0, -20)
		get_tree().current_scene.add_child(bullet)

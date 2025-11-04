extends Enemy

@export var bullet_scene: PackedScene
@export var fire_rate: float = 1.5
@onready var player = get_tree().get_first_node_in_group("player")
@onready var animated_sprite_2d = $AnimatedSprite2D

@export var amplitude: float = 60.0
@export var frequency: float = 2.0
var time_passed: float = 0.0
var start_x: float

func _ready():
	super._ready()
	start_x = position.x
	start_shooting()

func move_pattern(delta: float) -> void:
	time_passed += delta
	position.y += speed * delta
	position.x = start_x + sin(time_passed * frequency) * amplitude
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()

func start_shooting():
	shoot()
	var timer = Timer.new()
	timer.wait_time = fire_rate
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(shoot)

func shoot():
	if player == null:
		return
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.position = global_position
	var dir = (player.global_position - global_position).normalized()
	bullet.direction = dir

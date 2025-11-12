extends Node2D

@export var move_offset: Vector2 = Vector2(40, -20) # posição relativa ao Player
@export var bullet_scene: PackedScene
@export var fire_rate: float = 1.0

var player: Node = null
@onready var shoot_timer = $ShootTimer

func _ready():
	# procura o Player pelo grupo "player"
	var nodes = get_tree().get_nodes_in_group("player")
	if nodes.size() > 0:
		player = nodes[0]
	shoot_timer.wait_time = fire_rate

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player:
		# segue o Player com offset
		global_position = player.global_position + move_offset

func _on_shoot_timer_timeout():
	if bullet_scene and player:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position + Vector2(0, -10)
		bullet.power = player.stats.attack * 0.5 # exemplo: metade do poder do Player
		if bullet.power <= 0:
			bullet.power = 1 
		get_tree().current_scene.add_child(bullet)

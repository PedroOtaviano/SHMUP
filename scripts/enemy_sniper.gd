extends Enemy
class_name EnemySniper

@export var fire_rate: float = 2.5        # tempo entre disparos
@export var warning_time: float = 1.0     # tempo de aviso antes do tiro
@export var damage: int = 2               # dano do tiro
@export var contact_damage: int = 1       # dano ao encostar no player

@onready var player = get_tree().get_first_node_in_group("player")
@onready var line: Line2D = $Line2D

var moved_distance: float = 0.0
@export var move_limit: float = 150.0
var target_position: Vector2

func _ready():
	super._ready()
	line.visible = false

	# aplica gradiente no laser
	var gradient = Gradient.new()
	gradient.colors = [Color(1,1,1,1), Color(1,0,0,1)]
	var tex = GradientTexture1D.new()
	tex.gradient = gradient
	line.texture = tex
	line.texture_mode = Line2D.LINE_TEXTURE_STRETCH

	start_shooting()

func move_pattern(delta: float) -> void:
	if moved_distance < move_limit:
		var step = speed * delta
		position.y += step
		moved_distance += step
	# depois disso, fica parado

func start_shooting():
	var timer = Timer.new()
	timer.wait_time = fire_rate
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(prepare_shot)

func prepare_shot():
	if not player: return
	target_position = player.global_position

	line.visible = true
	line.width = 6
	line.default_color = Color(1, 0, 0, 0.4)
	line.points = [Vector2.ZERO, (target_position - global_position)]

	var tween = create_tween()
	tween.set_loops(int(warning_time / 0.4))
	tween.tween_property(line, "modulate:a", 0.1, 0.2)
	tween.tween_property(line, "modulate:a", 0.6, 0.2)

	await get_tree().create_timer(warning_time).timeout
	shoot()

func shoot():
	if target_position == null:
		line.visible = false
		return

	var dir = (target_position - global_position).normalized()
	var viewport_size = get_viewport_rect().size
	var max_length = viewport_size.length()

	line.visible = true
	line.width = 16
	line.default_color = Color(1, 0, 0, 1)
	line.points = [Vector2.ZERO, dir * max_length]

	var tween = create_tween()
	tween.tween_property(line, "width", 4, 0.15)
	tween.tween_property(line, "modulate:a", 0.0, 0.25)

	var space_state = get_world_2d().direct_space_state
	var start = global_position + dir * 10
	var query = PhysicsRayQueryParameters2D.create(start, start + dir * max_length)
	query.exclude = [self]
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)
	var hit_position = start + dir * max_length
	if result:
		var collider = result.collider
		if collider and collider.is_in_group("player") and collider.has_method("take_damage"):
			collider.take_damage(damage)
			hit_position = result.position

	var impact = preload("res://scenes/Effects/laser_impact.tscn").instantiate()
	get_parent().add_child(impact)
	impact.global_position = hit_position

	await get_tree().create_timer(0.25).timeout
	line.visible = false

# -------------------------
# Contato direto com Player
# -------------------------
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		var health_component = body.get_node_or_null("HealthComponent")
		if health_component:
			health_component.take_damage(contact_damage)
		explode()   # sniper morre ao encostar

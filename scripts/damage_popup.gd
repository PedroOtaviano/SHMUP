extends Label

@export var float_speed: float = 50.0
@export var lifetime: float = 0.8

var time_alive: float = 0.0

func _ready():
	z_index = 10
	modulate = Color(1, 1, 1, 1) # branco
	set_as_top_level(true) # não herda rotação/escala do inimigo

func _process(delta):
	time_alive += delta
	position.y -= float_speed * delta
	modulate.a = lerp(1.0, 0.0, time_alive / lifetime) # fade out

	if time_alive >= lifetime:
		queue_free()

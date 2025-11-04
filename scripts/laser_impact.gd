extends Node2D

@onready var particles = $GPUParticles2D
@onready var flash = $PointLight2D

func _ready():
	# dispara as partículas
	particles.emitting = true
	
	# faz o clarão sumir rápido
	var tween = create_tween()
	tween.tween_property(flash, "energy", 0.0, 0.2)
	
	# auto-destrói após o efeito
	await get_tree().create_timer(0.5).timeout
	queue_free()

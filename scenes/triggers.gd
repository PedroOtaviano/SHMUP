extends Node2D

@export var wave_index : int = 0
@export var spawner_path : NodePath
@export var stage_path : NodePath

var fired : bool = false

func _process(delta):
	if fired:
		return

	var stage = get_node_or_null(stage_path)
	var spawner = get_node_or_null(spawner_path)
	if stage == null or spawner == null:
		return

	var viewport_size = get_viewport_rect().size
	var screen_bottom = stage.scroll_offset.y + viewport_size.y

	# print("Trigger", name, "y =", global_position.y, " | screen_bottom =", screen_bottom)
	# print ("Stage.scroll_offset.y = %d", stage.scroll_offset.y)
	# print("Trigger", name, "global_position.y =", global_position.y)

	if stage.scroll_offset.y >= position.y: #posiçào é comparada localmente pois o trigger é filho do parallax
		fired = true
		spawner.spawn_wave_by_index(wave_index)
		print("Wave %d disparada!", wave_index)
		queue_free()

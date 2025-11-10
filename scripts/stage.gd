extends Node2D

@export var scroll_speed := Vector2(0, 100)
var scroll_offset := Vector2.ZERO

func _process(delta):
	scroll_offset += scroll_speed * delta

	for child in get_children():
		if child is Parallax2D:
			child.scroll_offset = scroll_offset * child.scroll_scale

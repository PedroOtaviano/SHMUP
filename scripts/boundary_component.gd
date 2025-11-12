extends Node
class_name BoundaryComponent

@export var margin: Vector2 = Vector2(16, 16) # espaço para não encostar na borda

func clamp_to_viewport(node: Node2D):
	var screen_rect = node.get_viewport_rect()
	node.position.x = clamp(node.position.x,
		screen_rect.position.x + margin.x,
		screen_rect.size.x - margin.x)
	node.position.y = clamp(node.position.y,
		screen_rect.position.y + margin.y,
		screen_rect.size.y - margin.y)

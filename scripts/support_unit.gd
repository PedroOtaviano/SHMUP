extends Area2D

@export var support_unit_name: String = "Support Drone Mk1"
@export var move_speed: float = 200.0

var target: Node = null

func _ready():
	# procura o Player (precisa estar no grupo "player")
	target = get_tree().get_first_node_in_group("player")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	if target:
		var dir = (target.global_position - global_position).normalized()
		global_position += dir * move_speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("add_support_unit"):
			body.add_support_unit(support_unit_name)
		show_pickup_text(support_unit_name)
		queue_free()

func show_pickup_text(text: String):
	var label = Label.new()
	label.text = "+ " + text
	label.modulate = Color(0.229, 0.367, 0.744, 1.0) # azul para diferenciar
	label.position = global_position
	get_tree().current_scene.add_child(label)

	var tween = get_tree().create_tween()
	tween.tween_property(label, "position:y", label.position.y - 30, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free)

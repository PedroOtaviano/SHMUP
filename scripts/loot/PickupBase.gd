extends Area2D
class_name PickupBase

@export var pickup_name: String = "Generic Pickup"
@export var move_speed: float = 200.0
@export var popup_color: Color = Color(1, 1, 1, 1) # cor padrão branca

var target: Node = null

func _ready():
	target = get_tree().get_first_node_in_group("player")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	if target:
		var dir = (target.global_position - global_position).normalized()
		global_position += dir * move_speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		var inventory = body.get_node_or_null("InventoryComponent")
		if inventory and inventory is InventoryComponent:
			apply_pickup(inventory)
		show_pickup_text(pickup_name)
		queue_free()

func apply_pickup(inventory: InventoryComponent) -> void:
	# método genérico, sobrescrito nas subclasses
	pass

func show_pickup_text(text: String):
	var label = Label.new()
	label.text = "+ " + text
	label.modulate = popup_color
	label.position = global_position
	get_tree().current_scene.add_child(label)

	var tween = get_tree().create_tween()
	tween.tween_property(label, "position:y", label.position.y - 30, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free)

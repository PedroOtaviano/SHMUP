extends CanvasLayer
class_name TutorialManager

@onready var tip_box = $TipBox
@onready var tip_label = $TipBox/TipLabel

var typing_speed := 0.05 # segundos por letra
var cursor_visible := true
var cursor_timer: Timer

func _ready():
	# Timer para piscar o cursor
	cursor_timer = Timer.new()
	cursor_timer.wait_time = 0.5
	cursor_timer.autostart = false
	cursor_timer.one_shot = false
	cursor_timer.timeout.connect(_toggle_cursor)
	add_child(cursor_timer)

func show_tip(text: String, duration: float = 4.0):
	tip_box.visible = true
	tip_box.modulate.a = 0.0
	tip_label.text = ""

	# fade-in da caixa
	var tween = create_tween()
	tween.tween_property(tip_box, "modulate:a", 1.0, 0.5)
	tween.tween_callback(Callable(self, "_start_typing").bind(text, duration))

func _start_typing(full_text: String, duration: float) -> void:
	tip_label.text = ""
	for i in full_text.length():
		tip_label.text += full_text[i]
		await get_tree().create_timer(typing_speed).timeout

	# inicia cursor piscando
	cursor_timer.start()

	# espera antes de fade-out
	await get_tree().create_timer(duration).timeout
	cursor_timer.stop()

	var tween = create_tween()
	tween.tween_property(tip_box, "modulate:a", 0.0, 0.5)
	tween.tween_callback(Callable(self, "_hide_tip"))

func _toggle_cursor():
	cursor_visible = !cursor_visible
	if cursor_visible:
		tip_label.text = tip_label.text.rstrip("|") + "|"
	else:
		tip_label.text = tip_label.text.rstrip("|")

func _hide_tip():
	tip_box.visible = false

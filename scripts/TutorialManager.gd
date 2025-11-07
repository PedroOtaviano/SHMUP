extends CanvasLayer
class_name TutorialManager

@onready var tip_box = $TipBox
@onready var tip_label = $TipBox/TipLabel

var typing_speed := 0.05 # segundos por letra
var cursor_visible := true
var cursor_timer: Timer
var full_text := ""
var cursor_color := "#00ffff"
var cursor_symbol_visible := "[color=#00ffff]▌[/color]"
var cursor_symbol_hidden := "[color=#00ffff] [/color]" # espaço coloridoity][/color]"

func _ready():
	cursor_timer = Timer.new()
	cursor_timer.wait_time = 0.5
	cursor_timer.autostart = false
	cursor_timer.one_shot = false
	cursor_timer.timeout.connect(_toggle_cursor)
	add_child(cursor_timer)

func show_tip(text: String, duration: float = 4.0):
	full_text = text
	tip_box.visible = true
	tip_box.modulate.a = 0.0
	tip_label.text = ""

	var tween = create_tween()
	tween.tween_property(tip_box, "modulate:a", 1.0, 0.5)
	tween.tween_callback(Callable(self, "_start_typing").bind(duration))

func _start_typing(duration: float) -> void:
	var partial := ""
	for i in full_text.length():
		partial += full_text[i]
		tip_label.text = "[color=%s]%s[/color]%s" % [cursor_color, partial, cursor_symbol_hidden]
		await get_tree().create_timer(typing_speed).timeout

	cursor_timer.start()
	await get_tree().create_timer(duration).timeout
	cursor_timer.stop()

	var tween = create_tween()
	tween.tween_property(tip_box, "modulate:a", 0.0, 0.5)
	tween.tween_callback(Callable(self, "_hide_tip"))

func _toggle_cursor():
	cursor_visible = !cursor_visible
	var clean_text: String = tip_label.text.replace(cursor_symbol_visible, "").replace(cursor_symbol_hidden, "")
	var cursor := cursor_symbol_visible if cursor_visible else cursor_symbol_hidden
	tip_label.text = clean_text + cursor

func _hide_tip():
	tip_box.visible = false

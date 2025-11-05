extends Control

@onready var lv_label = $HBoxContainer/VBoxContainer/LvLabel
@onready var hp_bar = $HBoxContainer/VBoxContainer/HPBar
@onready var xp_bar = $HBoxContainer/VBoxContainer/XPBar
@onready var shield_bar = $HBoxContainer/VBoxContainer/ShieldBar

var player

# Cores base
var hp_color = Color(1, 0, 0)
var shield_color = Color(0.2, 0.6, 1)
var xp_color = Color(1, 0.9, 0.2)

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if player:
		_set_progress_bar_color(hp_bar, hp_color)
		_set_progress_bar_color(shield_bar, shield_color)
		_set_progress_bar_color(xp_bar, xp_color)

		update_all()
		player.connect("stats_changed", Callable(self, "update_all"))

func _process(delta):
	if player:
		# Atualiza escudo em tempo real (regeneração)
		shield_bar.value = player.shield

		# Se o escudo está regenerando, aplica efeito de brilho
		if player.shield < player.stats.max_shield and player.shield > 0:
			var pulse = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 200.0)
			_set_progress_bar_color(shield_bar, shield_color.lerp(Color.WHITE, pulse * 0.3))
		else:
			_set_progress_bar_color(shield_bar, shield_color)

func update_all():
	if not player:
		return
	var s = player.stats

	# Level e XP
	lv_label.text = "LV" + str(s.level)
	xp_bar.max_value = s.xp_to_next
	xp_bar.value = s.xp

	# Vida
	hp_bar.max_value = s.max_health
	hp_bar.value = player.health

	# Escudo
	shield_bar.max_value = s.max_shield
	shield_bar.value = player.shield

# -------------------------
# Funções auxiliares
# -------------------------
func _set_progress_bar_color(bar: ProgressBar, fill_color: Color):
	var fill_box := StyleBoxFlat.new()
	fill_box.bg_color = fill_color
	bar.add_theme_stylebox_override("fill", fill_box)

	var bg_box := StyleBoxFlat.new()
	bg_box.bg_color = Color(fill_color.r, fill_color.g, fill_color.b, 0.25)
	bar.add_theme_stylebox_override("background", bg_box)

# -------------------------
# Feedback de dano
# Chamado pelo Player quando sofre dano
# -------------------------
func flash_hp_bar():
	_flash_bar(hp_bar, hp_color, Color.WHITE)

func flash_shield_bar():
	_flash_bar(shield_bar, shield_color, Color.WHITE)

func _flash_bar(bar: ProgressBar, base_color: Color, flash_color: Color):
	var tween = create_tween()
	tween.tween_callback(Callable(self, "_set_progress_bar_color").bind(bar, flash_color))
	tween.tween_interval(0.1)
	tween.tween_callback(Callable(self, "_set_progress_bar_color").bind(bar, base_color))

extends Control

@onready var progress_bar = $VBoxContainer/ProgressBar

func set_max_health(value: int):
	progress_bar.max_value = value
	progress_bar.value = value

func update_health(value: int):
	progress_bar.value = clamp(value, 0, progress_bar.max_value)

extends Node
class_name BossMovementComponent

const BossPhaseEnum = preload("res://scripts/enemy/boss/BossPhaseEnum.gd")

var boss
var time := 0.0
var entry_complete := false

@export var entry_target_y := 200.0
@export var entry_speed := 100.0
@export var lateral_amplitude := 100.0
@export var lateral_frequency := 1.5

func init(boss_ref):
	boss = boss_ref

func update(delta: float):
	if not entry_complete:
		move_entry(delta)
	else:
		move_pattern(delta)

func move_entry(delta: float):
	var target_y = entry_target_y
	if boss.global_position.y < target_y:
		boss.global_position.y += entry_speed * delta
	else:
		entry_complete = true

func move_pattern(delta: float):
	time += delta
	var phase = boss.get_phase()

	match phase:
		BossPhaseEnum.BossPhase.PHASE_ONE:
			# leve oscilação horizontal
			boss.global_position.x = boss.start_position.x + sin(time * lateral_frequency) * lateral_amplitude

		BossPhaseEnum.BossPhase.PHASE_TWO:
			# oscilação mais rápida e intensa
			boss.global_position.x = boss.start_position.x + sin(time * lateral_frequency * 1.5) * (lateral_amplitude * 1.2)

		BossPhaseEnum.BossPhase.PHASE_THREE:
			# parada ou leve tremor
			boss.global_position.x = boss.start_position.x + sin(time * 10.0) * 5.0

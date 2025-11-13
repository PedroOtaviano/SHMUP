extends Node
class_name BossPhaseComponent

const BossPhaseEnum = preload("res://scripts/enemy/boss/BossPhaseEnum.gd")

var boss
var current_phase: BossPhaseEnum.BossPhase = BossPhaseEnum.BossPhase.PHASE_ONE

@onready var sprite: AnimatedSprite2D = null
@onready var particles: GPUParticles2D = null

func init(boss_ref):
	boss = boss_ref
	sprite = boss.get_node("AnimatedSprite2D")
	particles = boss.get_node_or_null("PhaseParticles2D")

	current_phase = boss.get_phase()
	apply_phase_effects(current_phase)

func update():
	var new_phase = boss.get_phase()
	if new_phase != current_phase:
		current_phase = new_phase
		apply_phase_effects(current_phase)

func apply_phase_effects(phase: BossPhaseEnum.BossPhase):
	match phase:
		BossPhaseEnum.BossPhase.PHASE_ONE:
			if sprite: sprite.self_modulate = Color(1, 1, 1)
			if particles: particles.emitting = false

		BossPhaseEnum.BossPhase.PHASE_TWO:
			if sprite: sprite.self_modulate = Color(1, 0.7, 0.7)
			if particles:
				particles.emitting = true
				particles.amount = 80

		BossPhaseEnum.BossPhase.PHASE_THREE:
			if sprite: sprite.self_modulate = Color(0.441, 0.0, 0.05, 1.0)
			if particles:
				particles.emitting = true
				particles.amount = 150

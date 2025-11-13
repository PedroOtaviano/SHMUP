extends Node
class_name BossHealthBarComponent

const BossPhaseEnum = preload("res://scripts/enemy/boss/BossPhaseEnum.gd")

var boss
var health_bar: TextureProgressBar = null

func init(boss_ref):
	boss = boss_ref

	# Busca o primeiro nó no grupo "boss_hud"
	var hud_nodes = get_tree().get_nodes_in_group("boss_hud")
	if hud_nodes.size() > 0 and hud_nodes[0] is TextureProgressBar:
		health_bar = hud_nodes[0]

	if health_bar:
		health_bar.max_value = boss.max_health
		health_bar.value = boss.health
		update_visuals(boss.get_phase())

func update():
	if health_bar == null:
		return

	health_bar.value = boss.health
	update_visuals(boss.get_phase())

func update_visuals(phase: BossPhaseEnum.BossPhase):
	match phase:
		BossPhaseEnum.BossPhase.PHASE_ONE:
			health_bar.tint_progress = Color(0.2, 0.8, 0.2)  # verde

		BossPhaseEnum.BossPhase.PHASE_TWO:
			health_bar.tint_progress = Color(1.0, 0.6, 0.0)  # laranja

		BossPhaseEnum.BossPhase.PHASE_THREE:
			health_bar.tint_progress = Color(0.8, 0.0, 0.0)  # vermelho

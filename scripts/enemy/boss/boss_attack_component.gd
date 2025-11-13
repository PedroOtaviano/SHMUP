extends Node
class_name BossAttackComponent

const BossPhaseEnum = preload("res://scripts/enemy/boss/BossPhaseEnum.gd")

var boss: Boss
var angle_offset := 0.0

@export var fan_angles := [45, 60, 75, 90, 105, 120, 135]
@export var circle_interval := 0.5
@export var circle_interval_phase3 := 0.3

@onready var fan_timer: Timer = $FanTimer
@onready var circle_timer: Timer = $CircleTimer


func init(boss_ref: Boss):
	boss = boss_ref

	fan_timer.timeout.connect(_on_fan_timeout)
	fan_timer.start()

	circle_timer.timeout.connect(_on_circle_timeout)
	circle_timer.start()

func update(delta: float):
	var phase = boss.get_phase()
	if phase == BossPhaseEnum.BossPhase.PHASE_THREE:
		circle_timer.wait_time = circle_interval_phase3
	else:
		circle_timer.wait_time = circle_interval

func _on_fan_timeout():
	if boss.get_phase() <= BossPhaseEnum.BossPhase.PHASE_TWO:
		shoot_fan()

func _on_circle_timeout():
	if boss.get_phase() >= BossPhaseEnum.BossPhase.PHASE_TWO:
		shoot_circle(boss.shoot_point_left)
		shoot_circle(boss.shoot_point_right)
		angle_offset = fmod(angle_offset + boss.rotation_step, 360.0)

func shoot_fan():
	if boss.bullet_scene == null:
		return

	for angle in fan_angles:
		var bullet = boss.bullet_scene.instantiate()
		bullet.position = boss.global_position
		bullet.direction = Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle)))
		boss.get_parent().add_child(bullet)

func shoot_circle(marker: Marker2D):
	if boss.bullet_scene == null:
		return

	var step = 360.0 / boss.bullets_per_circle
	for i in range(boss.bullets_per_circle):
		var angle = deg_to_rad(i * step + angle_offset)
		var bullet = boss.bullet_scene.instantiate()
		bullet.global_position = marker.global_position
		bullet.direction = Vector2(cos(angle), sin(angle))
		boss.get_parent().add_child(bullet)

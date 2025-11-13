extends Enemy
class_name Boss

const BossPhaseEnum = preload("res://scripts/enemy/boss/BossPhaseEnum.gd")

@onready var attack_component      = $BossAttackComponent
@onready var phase_component       = $BossPhaseComponent
@onready var movement_component    = $BossMovementComponent
@onready var health_bar_component  = $BossHealthBarComponent
@onready var loot_component        = $BossLootComponent

@onready var shoot_point_left: Marker2D = $shoot_point_left
@onready var shoot_point_right: Marker2D = $shoot_point_right
@export var bullets_per_circle: int = 12   
@export var rotation_step: float = 10.0

@export var bullet_scene: PackedScene

var start_position: Vector2
 
func _ready():
	super._ready()
	attack_component.init(self)
	phase_component.init(self)
	movement_component.init(self)
	health_bar_component.init(self)
	loot_component.init(self)
	start_position = global_position

func get_phase() -> BossPhaseEnum.BossPhase:
	var percent = float(health) / float(max_health)
	if percent > 0.7:
		return BossPhaseEnum.BossPhase.PHASE_ONE
	elif percent > 0.3:
		return BossPhaseEnum.BossPhase.PHASE_TWO
	else:
		return BossPhaseEnum.BossPhase.PHASE_THREE

func move_pattern(delta := 0.0) -> void:
	movement_component.update(delta)

func attack_pattern(delta := 0.0) -> void:
	attack_component.update(delta)

func _process(delta: float) -> void:
	move_pattern(delta)
	phase_component.update()
	health_bar_component.update()

func die():
	loot_component.drop_loot()
	queue_free()

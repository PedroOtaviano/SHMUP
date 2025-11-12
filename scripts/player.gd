extends CharacterBody2D
class_name Player

@onready var health: HealthComponent = $HealthComponent
@onready var weapon: WeaponComponent = $WeaponComponent
@onready var inventory: InventoryComponent = $InventoryComponent
@onready var xp_component: XpComponent = $XPComponent
@onready var boundary: BoundaryComponent = $BoundaryComponent

var support_unit_paths := {
	"Support Drone Mk1": "res://scenes/SupportUnits/sumk_1.tscn",
	"Support Drone Mk2": "res://scenes/SupportUnits/sumk_2.tscn",
	"Support Drone Mk3": "res://scenes/SupportUnits/sumk_3.tscn"
}

func _ready():
	health.died.connect(_on_died)
	inventory.support_unit_added.connect(_on_support_unit_added)
	xp_component.leveled_up.connect(_on_leveled_up)

func _physics_process(delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("right"): direction.x += 1
	if Input.is_action_pressed("left"): direction.x -= 1
	if Input.is_action_pressed("up"): direction.y -= 1
	if Input.is_action_pressed("down"): direction.y += 1

	if direction != Vector2.ZERO:
		velocity = direction.normalized() * 200
		move_and_slide()

	boundary.clamp_to_viewport(self)

func _on_leveled_up(new_level: int):
	# exemplo: restaurar vida/escudo ao subir de nível
	health.current_health = health.max_health
	health.current_shield = health.max_shield
	print("Level UP! Agora nível %d" % new_level)

func _on_died():
	print("Player morreu!")
	queue_free()

func _on_support_unit_added(unit_name: String):
	var path = support_unit_paths.get(unit_name, "")
	if path == "":
		print("Support Unit não encontrada:", unit_name)
		return

	var unit_scene = load(path) # load aceita string dinâmica
	if not unit_scene:
		print("Falha ao carregar cena:", path)
		return

	# unidade à esquerda
	var left_unit = unit_scene.instantiate()
	left_unit.move_offset = Vector2(-60, -20)
	left_unit.bullet_scene = weapon.bullet_scene
	get_parent().add_child(left_unit)

	# unidade à direita
	var right_unit = unit_scene.instantiate()
	right_unit.move_offset = Vector2(60, -20)
	right_unit.bullet_scene = weapon.bullet_scene
	get_parent().add_child(right_unit)

	print("Support Units equipadas:", unit_name)

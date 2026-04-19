class_name Upgrade
extends AnimatableBody2D

enum Type {FIRE_RATE, DAMAGE, REPAIR, SUPER}

const FIRE_RATE_BOOST: float = 2.0
const DAMAGE_BOOST: float = 5.0
const SUPER_DURATION: float = 5.0

var type: Type = Type.FIRE_RATE

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	type = Type.values().pick_random()
	if type == Type.REPAIR:
		sprite_2d.frame = 1
	add_to_group("upgrade")

func _physics_process(delta: float) -> void:
	position.y += 50 * delta

func apply(ship: Ship) -> void:
	match type:
		Type.FIRE_RATE:
			ship.gun.normal_fire_rate += FIRE_RATE_BOOST
		Type.DAMAGE:
			ship.gun.normal_damage += DAMAGE_BOOST
		Type.REPAIR:
			pass
		Type.SUPER:
			_activate_super()
	queue_free()

func _activate_super() -> void:
	var guns := get_tree().get_nodes_in_group("gun")
	for gun: Gun in guns:
		gun.activate_super(SUPER_DURATION)

class_name Upgrade
extends AnimatableBody2D

enum Type {FIRE_RATE, DAMAGE, REPAIR, MAX_HEALTH, SUPER}

const FIRE_RATE_BOOST: float = 2.0
const DAMAGE_BOOST: float = 5.0
const REPAIR_AMOUNT: float = 30.0
const MAX_HEALTH_BOOST: float = 10.0
const SUPER_DURATION: float = 5.0

var type: Type = Type.FIRE_RATE
var _time: float = 0.0

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	type = Type.values().pick_random()
	if type == Type.REPAIR:
		sprite_2d.frame = 1
	elif type == Type.SUPER:
		sprite_2d.frame = 2
	elif type == Type.MAX_HEALTH:
		sprite_2d.frame = 3
	add_to_group("upgrade")

func _physics_process(delta: float) -> void:
	position.y += 50 * delta
	_time += delta
	sprite_2d.modulate.a = 0.5 + 0.5 * sin(_time * 8.0)

func apply(ship: Ship) -> void:
	match type:
		Type.FIRE_RATE:
			ship.gun.normal_fire_rate += FIRE_RATE_BOOST
		Type.DAMAGE:
			ship.gun.normal_damage += DAMAGE_BOOST
		Type.REPAIR:
			ship.heal(REPAIR_AMOUNT)
		Type.MAX_HEALTH:
			ship.increase_max_health(MAX_HEALTH_BOOST)
		Type.SUPER:
			_activate_super()
	queue_free()

func _activate_super() -> void:
	var guns := get_tree().get_nodes_in_group("gun")
	for gun: Gun in guns:
		gun.activate_super(SUPER_DURATION)

class_name Ship
extends Node2D

enum ShipType {MAIN, REFLECTION}

const PICKUP_RADIUS: float = 30.0

@export var ship_type: ShipType
@onready var gun: Gun = $Gun
@onready var chungus_ship: Sprite2D = $ChungusShip

func _ready() -> void:
	gun.ship_type = ship_type
	if ship_type == ShipType.REFLECTION:
		chungus_ship.frame = 1

func _physics_process(_delta: float) -> void:
	_check_upgrade_pickup()

func _check_upgrade_pickup() -> void:
	for upgrade in get_tree().get_nodes_in_group("upgrade"):
		if global_position.distance_to(upgrade.global_position) < PICKUP_RADIUS:
			upgrade.apply(self)

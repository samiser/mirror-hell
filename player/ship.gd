class_name Ship
extends Node2D

enum ShipType {MAIN, REFLECTION}

@export var ship_type: ShipType
@onready var gun: Gun = $Gun
@onready var chungus_ship: Sprite2D = $ChungusShip

func _ready() -> void:
	gun.ship_type = ship_type
	if ship_type == ShipType.REFLECTION:
		chungus_ship.frame = 1
		

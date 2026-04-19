class_name Ship
extends Node2D

enum ShipType {MAIN, REFLECTION}

@export var ship_type: ShipType
@onready var gun: Gun = $Gun

func _ready() -> void:
	gun.ship_type = ship_type

class_name Gun
extends Node2D

const BULLET = preload("uid://smgfahpj05cu")

var fire_rate: float = 100.0
var spread_angle: float = deg_to_rad(30.0)
var ship_type: Ship.ShipType

func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		var bullet_count: float = round(fire_rate * delta)
		for i in bullet_count:
			var bullet: Bullet = BULLET.instantiate()
			if ship_type == Ship.ShipType.REFLECTION:
				bullet.frame = 3
			bullet.global_position = global_position
			bullet.global_rotation = global_rotation + randf_range(-spread_angle / 2, spread_angle / 2)
			add_child(bullet)

class_name Shield
extends AnimatableBody2D

var health: float = 100.0
var max_health: float = 100.0
var speed: float = 50.0

@onready var sprite_2d: Sprite2D = $Sprite2D

func take_damage(amount: float) -> void:
	health -= amount
	sprite_2d.modulate.s = 1 - health / max_health * 1
	if health <= 0:
		queue_free()

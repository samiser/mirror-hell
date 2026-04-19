class_name BabyEnemy
extends AnimatableBody2D

enum Type {BLUE, RED}

var type: Type = Type.BLUE
var health: float = 50.0
var max_health: float = 50.0
var speed: float = 70.0
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	if type == Type.BLUE:
		add_to_group("blue")
	elif type == Type.RED:
		add_to_group("red")

func _physics_process(delta: float) -> void:
	position.y += speed * delta
	var turn : float = sin(Time.get_ticks_msec() * 0.0006) * 1.0
	position.x += turn
	rotation_degrees = -turn * 32.0

func take_damage(amount: float) -> void:
	health -= amount
	sprite_2d.modulate.s = 1 - health / max_health * 1
	if health <= 0:
		queue_free()

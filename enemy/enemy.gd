class_name Enemy
extends AnimatableBody2D

enum Type {BLUE, RED}

var type: Type = Type.BLUE
var health: float = 100.0
var max_health: float = 100.0
var speed: float = 50.0
@onready var shield: AnimatableBody2D = $Shield
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	if type == Type.BLUE:
		add_to_group("blue")
		shield.add_to_group("red")
	elif type == Type.RED:
		add_to_group("red")
		shield.add_to_group("blue")

func _physics_process(delta: float) -> void:
	position.y += speed * delta

func take_damage(amount: float) -> void:
	health -= amount
	sprite_2d.modulate.s = 1 - health / max_health * 1
	if health <= 0:
		queue_free()

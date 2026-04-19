class_name Enemy
extends AnimatableBody2D

const BULLET = preload("res://bullet/bullet.tscn")
const UPGRADE = preload("res://upgrades/upgrade.tscn")

enum Type {BLUE, RED}

var drop_chance: float = 0.2

var type: Type = Type.BLUE
var has_shield: bool = false

var health: float = 100.0
var max_health: float = 100.0
var speed: float = 50.0

var fire_rate: float = 1
var bullet_count: int = 3
var spread_angle: float = deg_to_rad(20.0)

var _fire_timer: float = 0.0

@onready var shield: AnimatableBody2D = $Shield
@onready var sprite_2d: Sprite2D = $Sprite2D

func apply_data(data: EnemyData) -> void:
	type = data.type
	has_shield = data.has_shield
	health = data.health
	max_health = data.health
	speed = data.speed
	fire_rate = data.fire_rate
	bullet_count = data.bullet_count
	spread_angle = deg_to_rad(data.spread_angle_degrees)

func _ready() -> void:
	if type == Type.BLUE:
		add_to_group("blue")
		shield.add_to_group("red")
	elif type == Type.RED:
		add_to_group("red")
		shield.add_to_group("blue")
	
	if not has_shield:
		shield.queue_free()

func _physics_process(delta: float) -> void:
	position.y += speed * delta

	_fire_timer += delta
	if _fire_timer >= fire_rate:
		_fire_timer -= fire_rate
		_shoot()

func _shoot() -> void:
	var start_angle := -spread_angle / 2.0
	var angle_step := spread_angle / (bullet_count - 1) if bullet_count > 1 else 0.0

	for i in bullet_count:
		var bullet: Bullet = BULLET.instantiate()
		bullet.global_position = global_position
		bullet.global_rotation = PI + start_angle + angle_step * i
		bullet.collision_mask = 2
		bullet.is_enemy_bullet = true
		bullet.speed = 375
		bullet.frame = 0
		get_tree().root.add_child(bullet)

func take_damage(amount: float) -> void:
	health -= amount
	sprite_2d.modulate.s = 1 - health / max_health * 1
	if health <= 0:
		_try_drop_upgrade()
		queue_free()

func _try_drop_upgrade() -> void:
	if randf() < drop_chance:
		var upgrade = UPGRADE.instantiate()
		upgrade.global_position = global_position
		get_tree().root.add_child(upgrade)

class_name Gun
extends Node2D

const BULLET = preload("uid://smgfahpj05cu")

var powered_up: bool = false
var ship_type: Ship.ShipType

var normal_fire_rate: float = 5.0
var normal_damage: float = 20.0

var powerup_fire_rate: float = 100.0
var powerup_spread: float = deg_to_rad(30.0)

var _fire_timer: float = 0.0

func _ready() -> void:
	add_to_group("gun")

func activate_super(duration: float) -> void:
	powered_up = true
	get_tree().create_timer(duration).timeout.connect(_deactivate_super)

func _deactivate_super() -> void:
	powered_up = false

func _process(delta: float) -> void:
	if not Input.is_action_pressed("shoot"):
		return

	if powered_up:
		_shoot_powered(delta)
	else:
		_shoot_normal(delta)

func _shoot_normal(delta: float) -> void:
	_fire_timer += delta
	var fire_interval := 1.0 / normal_fire_rate
	while _fire_timer >= fire_interval:
		_fire_timer -= fire_interval
		var bullet := _create_bullet()
		bullet.damage = normal_damage
		bullet.global_rotation = global_rotation
		add_child(bullet)
		$AudioStreamPlayer2D2.pitch_scale = randf_range(0.9, 1.1)
		$AudioStreamPlayer2D2.play()


func _shoot_powered(delta: float) -> void:

	var bullet_count := roundi(powerup_fire_rate * delta)
	for i in bullet_count:
		var bullet := _create_bullet()
		bullet.damage = normal_damage
		bullet.global_rotation = global_rotation + randf_range(-powerup_spread / 2, powerup_spread / 2)
		add_child(bullet)
		if randi() % 4 == 0:
			$AudioStreamPlayer2D2.pitch_scale = randf_range(0.8, 1.2)
			$AudioStreamPlayer2D2.play()
func _create_bullet() -> Bullet:
	var bullet: Bullet = BULLET.instantiate()
	bullet.global_position = global_position
	if ship_type == Ship.ShipType.REFLECTION:
		bullet.frame = 4
		bullet.ship_type = Ship.ShipType.REFLECTION
	else:
		bullet.frame = 2
	if randi() % 2 == 0:
		bullet.frame += 1
	return bullet

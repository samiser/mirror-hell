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
var dead : bool = false

var speed: float = 50.0

var fire_rate: float = 1
var bullet_count: int = 3
var spread_angle: float = deg_to_rad(20.0)

var _fire_timer: float = 0.0
var _can_fire: bool = true

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
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
	add_to_group("enemy")
	if type == Type.BLUE:
		add_to_group("blue")
		shield.add_to_group("red")
	elif type == Type.RED:
		add_to_group("red")
		shield.add_to_group("blue")

	if not has_shield:
		shield.queue_free()

func _physics_process(delta: float) -> void:
	if dead:
		return
	
	position.y += speed * delta

	if not _can_fire:
		return

	_fire_timer += delta
	if _fire_timer >= fire_rate:
		_fire_timer -= fire_rate
		_shoot()

func stop_firing() -> void:
	_can_fire = false

func _shoot() -> void:
	if dead:
		return
		
	var start_angle := -spread_angle / 2.0
	var angle_step := spread_angle / (bullet_count - 1) if bullet_count > 1 else 0.0

	for i in bullet_count:
		var bullet: Bullet = BULLET.instantiate()
		bullet.global_position = global_position
		bullet.global_rotation = PI + start_angle + angle_step * i
		bullet.collision_mask = 2
		bullet.is_enemy_bullet = true
		bullet.speed = 375
		bullet.damage = 10
		bullet.frame = 0
		get_tree().root.add_child(bullet)

func take_damage(amount: float) -> void:
	if dead:
		return
	
	health -= amount
	sprite_2d.modulate.s = 1 - health / max_health * 1
	
	audio_stream_player_2d.stream = load("res://assets/audio/hit_1.wav")
	audio_stream_player_2d.pitch_scale = randf_range(0.9, 1.1)
	audio_stream_player_2d.play()
	
	if health <= 0:
		_try_drop_upgrade()
		_die()
	else:
		var shake_count : int = 0
		var shake_magnitude : float = 2.0
		while shake_count < 6:
			sprite_2d.position += Vector2(randf_range(-shake_magnitude, shake_magnitude), randf_range(-shake_magnitude, shake_magnitude))
			var timer : SceneTreeTimer = get_tree().create_timer(0.1)
			await timer.timeout
			shake_count += 1
		sprite_2d.position = Vector2.ZERO

func block_damage() -> void:
	audio_stream_player_2d.stream = load("res://assets/audio/hit_4.wav")
	audio_stream_player_2d.play()
	
	var tween : Tween = get_tree().create_tween()
	var flash_colour : Color = Color.BLUE if type == Type.BLUE else Color.RED
	tween.tween_property(sprite_2d, "modulate", flash_colour, 0.1)
	tween.tween_property(sprite_2d, "modulate", Color.WHITE, 0.4)

func _try_drop_upgrade() -> void:
	if randf() < drop_chance:
		var upgrade = UPGRADE.instantiate()
		upgrade.global_position = global_position
		get_tree().root.add_child(upgrade)
		
func _die() -> void:
	dead = true
	sprite_2d.visible = false
	$CollisionPolygon2D.disabled = true
	
	audio_stream_player_2d.stream = load("res://assets/audio/boom_2.wav")
	audio_stream_player_2d.play()
	await audio_stream_player_2d.finished
	
	queue_free()

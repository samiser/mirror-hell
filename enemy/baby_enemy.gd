class_name BabyEnemy
extends AnimatableBody2D

enum Type {BLUE, RED}

const ENTER_THRESHOLD: float = 50.0
const FADE_IN_DURATION: float = 0.3

var type: Type = Type.BLUE
var health: float = 50.0
var max_health: float = 50.0
var speed: float = 70.0
var dead: bool = false
var _active: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("enemy")
	modulate.a = 0.0
	collision_shape.disabled = true
	if type == Type.BLUE:
		add_to_group("blue")
	elif type == Type.RED:
		add_to_group("red")
		sprite_2d.frame = 3

func _physics_process(delta: float) -> void:
	if dead:
		return

	position.y += speed * delta

	if position.y > get_viewport_rect().size.y + 50:
		_trigger_game_over()
		return

	if not _active:
		if position.y > ENTER_THRESHOLD:
			_activate()
		return

	var turn := sin(Time.get_ticks_msec() * 0.0006) * 1.0
	position.x += turn
	rotation_degrees = -turn * 32.0

func _activate() -> void:
	_active = true
	collision_shape.disabled = false
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_IN_DURATION)

func stop_firing() -> void:
	pass

func take_damage(amount: float) -> void:
	if dead or not _active:
		return
		
	health -= amount
	sprite_2d.modulate.s = 1 - health / max_health * 1
	
	audio_stream_player_2d.stream = load("res://assets/audio/hit_3.wav")
	audio_stream_player_2d.pitch_scale = randf_range(0.9, 1.1)
	audio_stream_player_2d.play()
	
	if health <= 0:
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
	var flash_colour : Color = Color.AQUA if type == Type.BLUE else Color.RED
	tween.tween_property(sprite_2d, "modulate", flash_colour, 0.1)
	tween.tween_property(sprite_2d, "modulate", Color.WHITE, 0.4)

func _die() -> void:
	dead = true
	sprite_2d.visible = false
	$CollisionShape2D.disabled = true

	audio_stream_player_2d.stream = load("res://assets/audio/boom_3.wav")
	audio_stream_player_2d.play()
	await audio_stream_player_2d.finished

	queue_free()

func _trigger_game_over() -> void:
	for ship in get_tree().get_nodes_in_group("player_ship"):
		ship.visible = false
		ship.set_physics_process(false)

	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.stop_firing()

	var game_over := get_node("/root/Main/UI/GameOver")
	game_over.visible = true

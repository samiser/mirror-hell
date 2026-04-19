class_name BabyEnemy
extends AnimatableBody2D

enum Type {BLUE, RED}

var type: Type = Type.BLUE
var health: float = 50.0
var max_health: float = 50.0
var speed: float = 70.0
var dead : bool = false
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	if type == Type.BLUE:
		add_to_group("blue")
	elif type == Type.RED:
		add_to_group("red")

func _physics_process(delta: float) -> void:
	if dead:
		return
	
	position.y += speed * delta
	var turn : float = sin(Time.get_ticks_msec() * 0.0006) * 1.0
	position.x += turn
	rotation_degrees = -turn * 32.0

func take_damage(amount: float) -> void:
	if dead:
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

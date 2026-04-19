extends Node2D

const ENEMY = preload("uid://ui8a1cy34oki")

var spawn_interval: float = 1.0
var spawn_x_min: float = 100.0
var spawn_x_max: float = 1000.0
var spawn_y: float = -100.0

var _spawn_timer: float = 0.0

func _process(delta: float) -> void:
	_spawn_timer += delta
	if _spawn_timer >= spawn_interval:
		_spawn_timer -= spawn_interval
		_spawn_enemy()

func _spawn_enemy() -> void:
	var enemy = ENEMY.instantiate()

	enemy.position.x = randf_range(spawn_x_min, spawn_x_max)
	enemy.position.y = spawn_y

	add_child(enemy)

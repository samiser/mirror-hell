extends Node2D

const ENEMY = preload("uid://ui8a1cy34oki")

var spawn_interval: float = 3.0
var spawn_margin: float = 100.0
var spawn_y: float = -100.0

var _spawn_timer: float = 0.0

func _process(delta: float) -> void:
	_spawn_timer += delta
	if _spawn_timer >= spawn_interval:
		_spawn_timer -= spawn_interval
		_spawn_enemy()

func _spawn_enemy() -> void:
	var center_x := get_viewport_rect().size.x / 2.0

	var x := randf_range(spawn_margin, center_x)
	var reflected_x := 2.0 * center_x - x

	var enemy1 = ENEMY.instantiate()
	enemy1.position = Vector2(x, spawn_y)
	add_child(enemy1)

	var enemy2 = ENEMY.instantiate()
	enemy2.position = Vector2(reflected_x, spawn_y)
	add_child(enemy2)

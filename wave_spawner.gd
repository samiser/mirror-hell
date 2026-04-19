class_name WaveSpawner
extends Node

const ENEMY = preload("uid://ui8a1cy34oki")
const ENEMY_BASIC = preload("res://enemy/enemy_basic.tres")
const ENEMY_FAST = preload("res://enemy/enemy_fast.tres")
const ENEMY_TANK = preload("res://enemy/enemy_tank.tres")

enum State { SPAWNING, WAITING, PAUSED }

var spawn_interval: float = 2.0
var spawn_margin: float = 100.0
var spawn_y: float = -100.0

var spawns_per_wave: int = 5
var wave_pause: float = 3.0

var _spawn_timer: float = 0.0
var _spawns_this_wave: int = 0
var _current_wave: int = 0
var _state: State = State.SPAWNING
var _alive_enemies: int = 0

var _wave_configs: Array[Array] = [
	[ENEMY_BASIC],
	[ENEMY_BASIC, ENEMY_FAST],
	[ENEMY_FAST, ENEMY_TANK],
	[ENEMY_BASIC, ENEMY_FAST, ENEMY_TANK],
]

func _process(delta: float) -> void:
	_spawn_timer += delta

	match _state:
		State.SPAWNING:
			if _spawn_timer >= spawn_interval:
				_spawn_timer -= spawn_interval
				_spawn_enemy()
				_spawns_this_wave += 1

				if _spawns_this_wave >= spawns_per_wave:
					_spawns_this_wave = 0
					_state = State.WAITING

		State.WAITING:
			if _alive_enemies <= 0:
				_spawn_timer = 0.0
				_state = State.PAUSED

		State.PAUSED:
			if _spawn_timer >= wave_pause:
				_spawn_timer = 0.0
				_current_wave += 1
				_state = State.SPAWNING

func _on_enemy_died() -> void:
	_alive_enemies -= 1

func _get_enemy_data() -> EnemyData:
	var wave_index := mini(_current_wave, _wave_configs.size() - 1)
	var pool: Array = _wave_configs[wave_index]
	return pool.pick_random()

func _spawn_enemy() -> void:
	var center_x := get_viewport().get_visible_rect().size.x / 2.0
	var x := randf_range(spawn_margin, center_x)
	var reflected_x := 2.0 * center_x - x
	var data := _get_enemy_data()

	var enemy1: Enemy = ENEMY.instantiate()
	enemy1.apply_data(data)
	enemy1.position = Vector2(x, spawn_y)
	enemy1.tree_exited.connect(_on_enemy_died)
	add_child(enemy1)
	_alive_enemies += 1

	var enemy2: Enemy = ENEMY.instantiate()
	enemy2.apply_data(data)
	enemy2.type = Enemy.Type.RED
	enemy2.position = Vector2(reflected_x, spawn_y)
	enemy2.tree_exited.connect(_on_enemy_died)
	add_child(enemy2)
	_alive_enemies += 1

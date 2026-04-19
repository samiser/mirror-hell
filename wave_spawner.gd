class_name WaveSpawner
extends Node

const ENEMY = preload("uid://ui8a1cy34oki")
const ENEMY_BASIC = preload("res://enemy/enemy_basic.tres")
const ENEMY_FAST = preload("res://enemy/enemy_fast.tres")
const ENEMY_TANK = preload("res://enemy/enemy_tank.tres")

enum State { SPAWNING, WAITING, PAUSED }

var spawn_margin: float = 100.0
var spawn_y: float = -100.0
var wave_pause: float = 1.0

var base_spawns: int = 2
var base_spawn_interval: float = 2.5

var fast_unlock_wave: int = 3
var tank_unlock_wave: int = 6

var _spawn_timer: float = 0.0
var _spawns_this_wave: int = 0
var _current_wave: int = 0
var _state: State = State.SPAWNING
var _alive_enemies: int = 0

var _fast_spawned_this_wave: int = 0
var _tank_spawned_this_wave: int = 0

func _process(delta: float) -> void:
	_spawn_timer += delta

	match _state:
		State.SPAWNING:
			if _spawn_timer >= _get_spawn_interval():
				_spawn_timer -= _get_spawn_interval()
				_spawn_enemy()
				_spawns_this_wave += 1

				if _spawns_this_wave >= _get_spawns_for_wave():
					_spawns_this_wave = 0
					_fast_spawned_this_wave = 0
					_tank_spawned_this_wave = 0
					_state = State.WAITING

		State.WAITING:
			if _alive_enemies <= 0:
				_spawn_timer = 0.0
				_state = State.PAUSED
				_heal_players()

		State.PAUSED:
			if _spawn_timer >= wave_pause:
				_spawn_timer = 0.0
				_current_wave += 1
				_state = State.SPAWNING

func _on_enemy_died() -> void:
	_alive_enemies -= 1

func _heal_players() -> void:
	for ship in get_tree().get_nodes_in_group("player_ship"):
		ship.heal_to_full()

func _get_spawns_for_wave() -> int:
	return base_spawns + _current_wave / 2

func _get_spawn_interval() -> float:
	return maxf(base_spawn_interval - _current_wave * 0.1, 1.0)

func _get_max_fast() -> int:
	if _current_wave < fast_unlock_wave:
		return 0
	return 1 + (_current_wave - fast_unlock_wave) / 2

func _get_max_tank() -> int:
	if _current_wave < tank_unlock_wave:
		return 0
	return 1 + (_current_wave - tank_unlock_wave) / 3

func _get_enemy_data() -> EnemyData:
	var available: Array[EnemyData] = [ENEMY_BASIC]
	var weights: Array[float] = [1.0]

	if _current_wave >= fast_unlock_wave and _fast_spawned_this_wave < _get_max_fast():
		available.append(ENEMY_FAST)
		weights.append(0.3 + (_current_wave - fast_unlock_wave) * 0.1)

	if _current_wave >= tank_unlock_wave and _tank_spawned_this_wave < _get_max_tank():
		available.append(ENEMY_TANK)
		weights.append(0.2 + (_current_wave - tank_unlock_wave) * 0.05)

	var picked := _weighted_pick(available, weights)

	if picked == ENEMY_FAST:
		_fast_spawned_this_wave += 1
	elif picked == ENEMY_TANK:
		_tank_spawned_this_wave += 1

	return picked

func _weighted_pick(items: Array[EnemyData], weights: Array[float]) -> EnemyData:
	var total := 0.0
	for w in weights:
		total += w
	var roll := randf() * total
	var cumulative := 0.0
	for i in items.size():
		cumulative += weights[i]
		if roll < cumulative:
			return items[i]
	return items[0]

func _spawn_enemy() -> void:
	var center_x := get_viewport().get_visible_rect().size.x / 2.0
	var x := randf_range(spawn_margin, center_x)
	var reflected_x := 2.0 * center_x - x
	var data := _get_enemy_data()

	var blue_on_left := randf() > 0.5
	var left_type := Enemy.Type.BLUE if blue_on_left else Enemy.Type.RED
	var right_type := Enemy.Type.RED if blue_on_left else Enemy.Type.BLUE

	var enemy1: Enemy = ENEMY.instantiate()
	enemy1.apply_data(data)
	enemy1.type = left_type
	enemy1.position = Vector2(x, spawn_y)
	enemy1.tree_exited.connect(_on_enemy_died)
	add_child(enemy1)
	_alive_enemies += 1

	var enemy2: Enemy = ENEMY.instantiate()
	enemy2.apply_data(data)
	enemy2.type = right_type
	enemy2.position = Vector2(reflected_x, spawn_y)
	enemy2.tree_exited.connect(_on_enemy_died)
	add_child(enemy2)
	_alive_enemies += 1

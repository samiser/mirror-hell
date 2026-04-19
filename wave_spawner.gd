class_name WaveSpawner
extends Node

const ENEMY = preload("uid://ui8a1cy34oki")
const BABY_ENEMY = preload("res://enemy/baby_enemy.tscn")
const ENEMY_BASIC = preload("res://enemy/enemy_basic.tres")
const ENEMY_FAST = preload("res://enemy/enemy_fast.tres")
const ENEMY_TANK = preload("res://enemy/enemy_tank.tres")

enum State { SPAWNING, WAITING, PAUSED }
enum EnemyType { BASIC, FAST, BABY, TANK }

var spawn_margin: float = 100.0
var spawn_y: float = -100.0
var wave_pause: float = 1.0

var base_spawns: int = 2
var base_spawn_interval: float = 2.5

var fast_unlock_wave: int = 3
var baby_unlock_wave: int = 4
var tank_unlock_wave: int = 6

var _spawn_timer: float = 0.0
var _spawns_this_wave: int = 0
var _current_wave: int = 0
var _state: State = State.SPAWNING
var _alive_enemies: int = 0

var _fast_spawned_this_wave: int = 0
var _baby_spawned_this_wave: int = 0
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
					_baby_spawned_this_wave = 0
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

func _get_max_baby() -> int:
	if _current_wave < baby_unlock_wave:
		return 0
	return 1 + (_current_wave - baby_unlock_wave) / 2

func _get_max_tank() -> int:
	if _current_wave < tank_unlock_wave:
		return 0
	return 1 + (_current_wave - tank_unlock_wave) / 3

func _pick_enemy_type() -> EnemyType:
	var available: Array[EnemyType] = [EnemyType.BASIC]
	var weights: Array[float] = [1.0]

	if _current_wave >= fast_unlock_wave and _fast_spawned_this_wave < _get_max_fast():
		available.append(EnemyType.FAST)
		weights.append(0.3 + (_current_wave - fast_unlock_wave) * 0.1)

	if _current_wave >= baby_unlock_wave and _baby_spawned_this_wave < _get_max_baby():
		available.append(EnemyType.BABY)
		weights.append(0.4 + (_current_wave - baby_unlock_wave) * 0.1)

	if _current_wave >= tank_unlock_wave and _tank_spawned_this_wave < _get_max_tank():
		available.append(EnemyType.TANK)
		weights.append(0.2 + (_current_wave - tank_unlock_wave) * 0.05)

	var picked := _weighted_pick_type(available, weights)

	match picked:
		EnemyType.FAST:
			_fast_spawned_this_wave += 1
		EnemyType.BABY:
			_baby_spawned_this_wave += 1
		EnemyType.TANK:
			_tank_spawned_this_wave += 1

	return picked

func _weighted_pick_type(items: Array[EnemyType], weights: Array[float]) -> EnemyType:
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
	var center_margin := 15.0
	var x := randf_range(spawn_margin, center_x - center_margin)
	var reflected_x := 2.0 * center_x - x

	var blue_on_left := randf() > 0.5
	var left_color := Enemy.Type.BLUE if blue_on_left else Enemy.Type.RED
	var right_color := Enemy.Type.RED if blue_on_left else Enemy.Type.BLUE

	var enemy_type := _pick_enemy_type()

	if enemy_type == EnemyType.BABY:
		_spawn_baby_pair(x, reflected_x, blue_on_left)
	else:
		_spawn_enemy_pair(x, reflected_x, left_color, right_color, enemy_type)

func _spawn_enemy_pair(x: float, reflected_x: float, left_color: Enemy.Type, right_color: Enemy.Type, enemy_type: EnemyType) -> void:
	var data: EnemyData
	match enemy_type:
		EnemyType.BASIC:
			data = ENEMY_BASIC
		EnemyType.FAST:
			data = ENEMY_FAST
		EnemyType.TANK:
			data = ENEMY_TANK

	var enemy1: Enemy = ENEMY.instantiate()
	enemy1.apply_data(data)
	enemy1.type = left_color
	enemy1.position = Vector2(x, spawn_y)
	enemy1.tree_exited.connect(_on_enemy_died)
	add_child(enemy1)
	_alive_enemies += 1

	var enemy2: Enemy = ENEMY.instantiate()
	enemy2.apply_data(data)
	enemy2.type = right_color
	enemy2.position = Vector2(reflected_x, spawn_y)
	enemy2.tree_exited.connect(_on_enemy_died)
	add_child(enemy2)
	_alive_enemies += 1

func _spawn_baby_pair(x: float, reflected_x: float, blue_on_left: bool) -> void:
	var baby1: BabyEnemy = BABY_ENEMY.instantiate()
	baby1.type = BabyEnemy.Type.BLUE if blue_on_left else BabyEnemy.Type.RED
	baby1.position = Vector2(x, spawn_y)
	baby1.tree_exited.connect(_on_enemy_died)
	add_child(baby1)
	_alive_enemies += 1

	var baby2: BabyEnemy = BABY_ENEMY.instantiate()
	baby2.type = BabyEnemy.Type.RED if blue_on_left else BabyEnemy.Type.BLUE
	baby2.position = Vector2(reflected_x, spawn_y)
	baby2.tree_exited.connect(_on_enemy_died)
	add_child(baby2)
	_alive_enemies += 1

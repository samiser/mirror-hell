class_name Ship
extends Node2D

enum ShipType {MAIN, REFLECTION}

const PICKUP_RADIUS: float = 30.0

var health: float = 100.0
var max_health: float = 100.0
var _health_bar_width_increment: float

@export var ship_type: ShipType
@onready var gun: Gun = $Gun
@onready var chungus_ship: Sprite2D = $ChungusShip
@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	add_to_group("player_ship")
	gun.ship_type = ship_type
	if ship_type == ShipType.REFLECTION:
		chungus_ship.frame = 1
	_health_bar_width_increment = health_bar.size.x * 0.1
	_update_health_bar()

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		health = 0
		_trigger_game_over()
	_update_health_bar()

func _trigger_game_over() -> void:
	for ship in get_tree().get_nodes_in_group("player_ship"):
		ship.visible = false
		ship.set_physics_process(false)

	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.stop_firing()

	var game_over := get_node("/root/Main/UI/GameOver")
	game_over.visible = true

func heal(amount: float) -> void:
	health = minf(health + amount, max_health)
	_update_health_bar()

func increase_max_health(amount: float) -> void:
	max_health += amount
	health += amount
	health_bar.size.x += _health_bar_width_increment
	_update_health_bar()

func _update_health_bar() -> void:
	health_bar.max_value = max_health
	health_bar.value = health

func _physics_process(_delta: float) -> void:
	_check_upgrade_pickup()

func _check_upgrade_pickup() -> void:
	for upgrade in get_tree().get_nodes_in_group("upgrade"):
		if global_position.distance_to(upgrade.global_position) < PICKUP_RADIUS:
			upgrade.apply(self)

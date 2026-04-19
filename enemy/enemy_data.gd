class_name EnemyData
extends Resource

@export var type: Enemy.Type = Enemy.Type.BLUE
@export var has_shield: bool = false

@export var health: float = 100.0
@export var speed: float = 50.0

@export var fire_rate: float = 1.0
@export var bullet_count: int = 3
@export var spread_angle_degrees: float = 20.0

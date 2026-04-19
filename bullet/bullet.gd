class_name Bullet
extends Sprite2D

const BULLET_SHAPE = preload("res://bullet/bullet_shape.tres")

var max_range: float = 1200.0
var speed: float = 750
var collision_mask: int = 1
var ship_type: Ship.ShipType = Ship.ShipType.MAIN

var _travelled_distance: float = 0.0

var direction : Vector2
var deflected : bool = false

func _ready() -> void:
	direction = -transform.y
	top_level = true

func _physics_process(delta: float) -> void:
	var distance := speed * delta
	var motion := direction * speed * delta
	
	if not deflected:
		var space_state := get_world_2d().direct_space_state
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape_rid = BULLET_SHAPE.get_rid()
		query.transform = global_transform
		query.collision_mask = collision_mask
		query.collide_with_areas = true
		query.collide_with_bodies = true

		var hits := space_state.intersect_shape(query, 1)
		if hits.size() > 0:
			_on_hit(hits[0].collider)
			return

		query.motion = motion
		var result := space_state.cast_motion(query)
		if result[0] < 1.0:
			position += motion * result[1]
			query.transform = global_transform
			query.motion = Vector2.ZERO
			hits = space_state.intersect_shape(query, 1)
			if hits.size() > 0:
				_on_hit(hits[0].collider)
			return

	position += motion
	_travelled_distance += distance

	if _travelled_distance >= max_range:
		queue_free()

var damage: float = 1
var is_enemy_bullet: bool = false

func _on_hit(collider: Object) -> void:
	if collider.has_method("take_damage"):
		if is_enemy_bullet:
			collider.take_damage(damage)
		elif collider.is_in_group("blue") and ship_type == Ship.ShipType.REFLECTION:
			collider.take_damage(damage)
		elif collider.is_in_group("red") and ship_type == Ship.ShipType.MAIN:
			collider.take_damage(damage)
		else:
			collider.block_damage()
			modulate.a = 0.5
			flip_v = true
			direction = Vector2(randf_range(-0.4, 0.4), 1)
			deflected = true
			return
	
	queue_free()

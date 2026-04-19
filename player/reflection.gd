extends Node2D

func _process(delta: float) -> void:
	position = get_global_mouse_position() * Vector2(-1, 1) + Vector2(get_viewport_rect().size.x, 0)
	position.x = clampf(position.x, 20, 628)
	position.y = clampf(position.y, 30, 1122)

extends Node2D

func _process(delta: float) -> void:
	position = get_global_mouse_position() * Vector2(-1, 1) + Vector2(get_viewport_rect().size.x, 0)

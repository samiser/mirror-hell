extends Node2D

func _process(delta: float) -> void:
	position = get_global_mouse_position()
	position.x = clampf(position.x, 20, 628)
	position.y = clampf(position.y, 30, 1122)

extends Node2D

@onready var play: Button = $Control/VBoxContainer/CenterContainer/Play
const MAIN = preload("uid://bai1mbf7pjv71")

func _ready() -> void:
	play.pressed.connect(func() -> void: get_tree().change_scene_to_packed(MAIN))

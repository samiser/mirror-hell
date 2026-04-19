extends Control

@onready var retry: Button = $CenterContainer/Panel/VBoxContainer/Retry
@onready var main_menu: Button = $CenterContainer/Panel/VBoxContainer/MainMenu

func _ready() -> void:
	retry.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://main.tscn"))
	main_menu.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://ui/main_menu.tscn"))

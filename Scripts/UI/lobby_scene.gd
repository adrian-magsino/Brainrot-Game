extends Control

@onready var selectmode: Control = $Selectmode
@onready var selectmap: Control = $Selectmap


func _on_select_map_pressed() -> void:
	selectmap.visible = true

func _on_select_mode_pressed() -> void:
	selectmode.visible = true

func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/JoinmenuScene.tscn")

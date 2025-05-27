extends Control

func _on_escape_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Gameplay/TESTING_GROUND.tscn")

func _on_survival_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Gameplay/backroom_map.tscn")
	
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainmenuScene.tscn")

extends Control

func _on_escape_pressed() -> void:
	ButtonClick.play_button_click()
	get_tree().change_scene_to_file("res://Scenes/UI/LevelScene.tscn")

func _on_survival_pressed() -> void:
	ButtonClick.play_button_click()
	get_tree().change_scene_to_file("res://Scenes/Survival Levels/survival1_backrooms.tscn")
	
func _on_back_pressed() -> void:
	ButtonClick.play_button_click()
	get_tree().change_scene_to_file("res://Scenes/UI/MainmenuScene.tscn")

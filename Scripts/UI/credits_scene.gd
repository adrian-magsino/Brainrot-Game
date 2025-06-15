extends Control


func _on_back_pressed() -> void:
	ButtonClick.play_button_click()
	get_tree().change_scene_to_file("res://Scenes/UI/MainmenuScene.tscn")

extends Control

func _on_create_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/LobbyScene.tscn")

func _on_join_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/JoinlistScene.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainmenuScene.tscn")

extends Control

func _ready() -> void:
	Global.load_game()  # Load game data here

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/ModemenuScene.tscn")

func _on_settings_pressed() -> void:
	#get_tree().change_scene_to_file()
	pass
	
func _on_credits_pressed() -> void:
	#get_tree().change_scene_to_file()
	pass
	
func _on_quit_pressed() -> void:
	get_tree().quit()

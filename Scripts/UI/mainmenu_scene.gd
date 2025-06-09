extends Control

func _ready() -> void:
	PLAYER_DATA.load_game()  # Load game data here
	GAME_PROGRESS.load_progress()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/ModemenuScene.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/SettingsScene.tscn")
	
func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/CreditsScene.tscn")
	
	
func _on_quit_pressed() -> void:
	GAME_PROGRESS.save_progress()
	get_tree().quit()

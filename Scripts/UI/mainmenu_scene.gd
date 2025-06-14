extends Control

func _ready() -> void:
	PLAYER_DATA.load_game()  # Load game data here
	PLAYER_DATA.apply_saved_audio_settings()
	GAME_PROGRESS.load_progress()
	
	if not Bgm.playing:
		Bgm.play()
	
func _on_play_pressed() -> void:
	ButtonClick.play_button_click()
	get_tree().change_scene_to_file("res://Scenes/UI/ModemenuScene.tscn")
	
func _on_settings_pressed() -> void:
	ButtonClick.play_button_click()
	get_tree().change_scene_to_file("res://Scenes/UI/SettingsScene.tscn")
	
func _on_credits_pressed() -> void:
	ButtonClick.play_button_click()
	get_tree().change_scene_to_file("res://Scenes/UI/CreditsScene.tscn")
	
	
func _on_quit_pressed() -> void:
	ButtonClick.play_button_click()
	GAME_PROGRESS.save_progress()
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

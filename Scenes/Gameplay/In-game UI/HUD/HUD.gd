extends CanvasLayer

@onready var menu_panel = $Menu
@onready var victory_panel: Control = $GameResults/VictoryPanel
@onready var defeat_panel: Control = $GameResults/DefeatPanel
@onready var game_scene = get_parent()
@onready var settings: Control = $Menu/Settings

func _ready():
	victory_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	defeat_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	
func _on_menu_button_pressed() -> void:
	ButtonClick.play_button_click()
	menu_panel.visible = not menu_panel.visible
	if game_scene.has_method("pause_level"):
		game_scene.pause_level()
	
func _on_resume_button_pressed() -> void:
	ButtonClick.play_button_click()
	menu_panel.visible = false
	if game_scene.has_method("unpause_level"):
		game_scene.unpause_level()

func _on_settings_button_pressed() -> void:
	ButtonClick.play_button_click()
	settings.visible = true
	
func _on_exit_button_pressed() -> void:
	ButtonClick.play_button_click()
	Map1Music.stop()
	Map2Music.stop()
	Map3Music.stop()
	SurvivalMusic.stop()
	get_tree().change_scene_to_file("res://Scenes/UI/MainmenuScene.tscn")
	
func _on_next_level_button_pressed() -> void:
	ButtonClick.play_button_click()
	get_tree().change_scene_to_file("res://Scenes/UI/LevelScene.tscn")

func _on_retry_button_pressed() -> void:
	ButtonClick.play_button_click()
	var current_scene = get_tree().current_scene
	var scene_path = current_scene.scene_file_path
	get_tree().change_scene_to_file(scene_path)
	
func _on_back_pressed() -> void:
	ButtonClick.play_button_click()

	# Revert all audio settings
	$Menu/Settings/SoundContainer/VBoxContainer/Master.reset_to_original()
	$Menu/Settings/SoundContainer/VBoxContainer/Music.reset_to_original()
	$Menu/Settings/SoundContainer/VBoxContainer/SFX.reset_to_original()
	
	settings.visible = false

func _on_apply_pressed() -> void:
	ButtonClick.play_button_click()
	PLAYER_DATA.save_game()
	
	settings.visible = false

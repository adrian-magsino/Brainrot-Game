extends CanvasLayer

@onready var menu_panel = $Menu/MenuPanel
@onready var victory_panel: Control = $GameResults/VictoryPanel
@onready var defeat_panel: Control = $GameResults/DefeatPanel
@onready var game_scene = get_parent()

func _ready():
	victory_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	defeat_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	
func _on_menu_button_pressed() -> void:
	menu_panel.visible = not menu_panel.visible
	if game_scene.has_method("pause_level"):
		game_scene.pause_level()
	
func _on_resume_button_pressed() -> void:
	menu_panel.visible = false
	if game_scene.has_method("unpause_level"):
		game_scene.unpause_level()

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainmenuScene.tscn")
	
func _on_next_level_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/LevelScene.tscn")

func _on_retry_button_pressed() -> void:
	var current_scene = get_tree().current_scene
	var scene_path = current_scene.scene_file_path
	get_tree().change_scene_to_file(scene_path)

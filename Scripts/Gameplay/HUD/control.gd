extends Control

@onready var menu_panel = $Menu/MenuPanel
@onready var victory_panel = $VictoryScreen/VictoryPanel

func _ready():
	victory_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	
func _on_menu_button_pressed() -> void:
	menu_panel.visible = not menu_panel.visible
	
func _on_exit_button_pressed() -> void:
	
	get_tree().change_scene_to_file("res://Scenes/UI/MainmenuScene.tscn")
	
func _on_resume_button_pressed() -> void:
	menu_panel.visible = false

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.

func _on_next_level_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/LevelScene.tscn")

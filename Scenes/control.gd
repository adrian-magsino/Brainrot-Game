extends Control

@onready var menu_panel = $Menu/MenuPanel
func _on_menu_button_pressed() -> void:
	menu_panel.visible = not menu_panel.visible
	
func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
func _on_resume_button_pressed() -> void:
	menu_panel.visible = false

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.

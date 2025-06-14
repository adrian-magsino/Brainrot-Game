extends Control
@onready var player: Control = $Player
@onready var sound: Control = $Sound
@onready var input_box: LineEdit = $Player/LineEdit
@onready var saved_text: Label = $SavedText
@onready var timer: Timer = $Timer
@onready var char_selection: HBoxContainer = $Player/CharSelection

func _ready():
	PLAYER_DATA.load_game()
	input_box.text = PLAYER_DATA.player_name if PLAYER_DATA.player_name != null else ""
	
func _on_player_button_pressed() -> void:
	player.visible = true
	sound.visible = false

func _on_sound_button_pressed() -> void:
	sound.visible = true
	player.visible = false

func _on_back_button_pressed() -> void:
	ButtonClick.play_button_click()
	get_tree().change_scene_to_file("res://Scenes/UI/MainmenuScene.tscn")


func _on_line_edit_text_submitted(new_text: String) -> void:
	input_box.release_focus()  # hide keyboard on enter


func _on_apply_button_pressed() -> void:
	ButtonClick.play_button_click()
	PLAYER_DATA.player_name = input_box.text
	PLAYER_DATA.save_game()
	
	show_saved_message()
	
func show_saved_message() -> void:
	saved_text.visible = true
	timer.start()

func _on_timer_timeout() -> void:
	saved_text.visible = false

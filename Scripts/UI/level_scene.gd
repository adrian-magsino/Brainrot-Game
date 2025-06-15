extends Control

@onready var level_1: TextureButton = $TextureRect/HBoxContainer/Level1
@onready var level_3: TextureButton = $TextureRect/HBoxContainer/Level3
@onready var level_5: TextureButton = $TextureRect/HBoxContainer/Level5
@onready var level_7: TextureButton = $TextureRect/HBoxContainer/Level7
@onready var level_9: TextureButton = $TextureRect/HBoxContainer/Level9
@onready var level_2: TextureButton = $TextureRect/HBoxContainer2/Level2
@onready var level_4: TextureButton = $TextureRect/HBoxContainer2/Level4
@onready var level_6: TextureButton = $TextureRect/HBoxContainer2/Level6
@onready var level_8: TextureButton = $TextureRect/HBoxContainer2/Level8
@onready var level_10: TextureButton = $TextureRect/HBoxContainer2/Level10


func _ready() -> void:
	# Load progress first if not done already
	GAME_PROGRESS.load_progress()

	level_2.disabled = !GAME_PROGRESS.level_completed["lvl1"]
	level_3.disabled = !GAME_PROGRESS.level_completed["lvl2"]
	level_4.disabled = !GAME_PROGRESS.level_completed["lvl3"]
	level_5.disabled = !GAME_PROGRESS.level_completed["lvl4"]
	level_6.disabled = !GAME_PROGRESS.level_completed["lvl5"]
	level_7.disabled = !GAME_PROGRESS.level_completed["lvl6"]
	level_8.disabled = !GAME_PROGRESS.level_completed["lvl7"]
	level_9.disabled = !GAME_PROGRESS.level_completed["lvl8"]
	level_10.disabled = !GAME_PROGRESS.level_completed["lvl9"]



func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_1.tscn")

func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_2.tscn")
	
func _on_level_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_3.tscn")

func _on_level_4_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_4.tscn")

func _on_level_5_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_5.tscn")

func _on_level_6_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_6.tscn")

func _on_level_7_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_7.tscn")

func _on_level_8_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_8.tscn")

func _on_level_9_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_9.tscn")

func _on_level_10_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_10.tscn")

func _on_back_button_pressed() -> void:
	ButtonClick.play_button_click()
	get_tree().change_scene_to_file("res://Scenes/UI/ModemenuScene.tscn")

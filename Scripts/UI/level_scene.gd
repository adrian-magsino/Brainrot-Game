extends Control

@onready var level_1: TextureButton = $LevelContainer/HBoxContainer/Theme1/Level1
@onready var level_2: TextureButton = $LevelContainer/HBoxContainer/Theme1/Level2
@onready var level_3: TextureButton = $LevelContainer/HBoxContainer/Theme1/Level3
@onready var level_4: TextureButton = $LevelContainer/HBoxContainer/Theme2/Level4
@onready var level_5: TextureButton = $LevelContainer/HBoxContainer/Theme2/Level5
@onready var level_6: TextureButton = $LevelContainer/HBoxContainer/Theme2/Level6
@onready var level_7: TextureButton = $LevelContainer/HBoxContainer/Theme3/Level7
@onready var level_8: TextureButton = $LevelContainer/HBoxContainer/Theme3/Level8
@onready var level_9: TextureButton = $LevelContainer/HBoxContainer/Theme3/Level9
@onready var level_10: TextureButton = $LevelContainer/HBoxContainer/Theme3/Level10

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
	get_tree().change_scene_to_file("res://Scenes/Gameplay/TESTING_GROUND.tscn")

func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_2.tscn")
	print("level2")
	
func _on_level_3_pressed() -> void:
	pass # Replace with function body.

func _on_level_4_pressed() -> void:
	pass # Replace with function body.

func _on_level_5_pressed() -> void:
	pass # Replace with function body.

func _on_level_6_pressed() -> void:
	pass # Replace with function body.

func _on_level_7_pressed() -> void:
	pass # Replace with function body.

func _on_level_8_pressed() -> void:
	pass # Replace with function body.

func _on_level_9_pressed() -> void:
	pass # Replace with function body.

func _on_level_10_pressed() -> void:
	pass # Replace with function body.

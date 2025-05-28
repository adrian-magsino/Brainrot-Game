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
	
	if LevelCore.lvl1_completed == true:
		level_2.disabled = false
	if LevelCore.lvl2_completed == true:
		level_3.disabled = false
	if LevelCore.lvl3_completed == true:
		level_4.disabled = false
	if LevelCore.lvl4_completed == true:
		level_5.disabled = false
	if LevelCore.lvl5_completed == true:
		level_6.disabled = false
	if LevelCore.lvl6_completed == true:
		level_7.disabled = false
	if LevelCore.lvl7_completed == true:
		level_8.disabled = false
	if LevelCore.lvl8_completed == true:
		level_9.disabled = false	
	if LevelCore.lvl9_completed == true:
		level_10.disabled = false



func _on_level_1_pressed() -> void:
	print("level1")

func _on_level_2_pressed() -> void:
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

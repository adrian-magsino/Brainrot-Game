extends Node

@onready var gamemap_label: Label = $Description/Gamemode
@onready var description_label: RichTextLabel = $Description/Description
@onready var map_images = $Maps.get_children()
@onready var selectmap: Control = $"."
@onready var map_buttons = get_node("../select_map").get_children()


var game_maps: Array[Dictionary] = [
	{"name": "Map1", "description": "Map 1 description description description."},
	{"name": "Map2", "description": "Map 2 description description description."},
	{"name": "Map3", "description": "Map 3 description description description."},
]

var current_map_index: int = 0

func _ready() -> void:
	update_mode_display()

func _on_left_pressed() -> void:
	current_map_index = (current_map_index - 1 + game_maps.size()) % game_maps.size()
	update_mode_display()

func _on_right_pressed() -> void:
	current_map_index = (current_map_index + 1) % game_maps.size()
	update_mode_display()

func update_mode_display() -> void:
	var map: Dictionary = game_maps[current_map_index]
	gamemap_label.text = map["name"]
	description_label.text = map["description"]

	# Show only the active map image
	for i in range(map_images.size()):
		map_images[i].visible = (i == current_map_index)

func _on_select_pressed() -> void:
	for i in range(map_buttons.size()):
		map_buttons[i].visible = (i == current_map_index)
		
	selectmap.visible = false

func _on_back_to_lobby_pressed() -> void:
	selectmap.visible = false

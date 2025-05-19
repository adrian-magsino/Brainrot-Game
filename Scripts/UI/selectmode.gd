extends Node

@onready var gamemode_label: Label = $Description/Gamemode
@onready var description_label: RichTextLabel = $Description/Description
@onready var mode_images = $Modes.get_children()
@onready var selectmode: Control = $"."
@onready var mode_buttons = get_node("../select_mode").get_children()

# Dictionary matches UI image nodes (Mode1, Mode2...) by index
var game_modes: Array[Dictionary] = [
	{"name": "Mode1", "description": "Standard rules with balanced gameplay."},
	{"name": "Mode2", "description": "Race against the clock to win."},
]

var current_mode_index: int = 0

func _ready() -> void:
	update_mode_display()

func _on_left_pressed() -> void:
	current_mode_index = (current_mode_index - 1 + game_modes.size()) % game_modes.size()
	update_mode_display()

func _on_right_pressed() -> void:
	current_mode_index = (current_mode_index + 1) % game_modes.size()
	update_mode_display()

func update_mode_display() -> void:
	var mode: Dictionary = game_modes[current_mode_index]
	gamemode_label.text = mode["name"]
	description_label.text = mode["description"]

	# Show only the active mode image
	for i in range(mode_images.size()):
		mode_images[i].visible = (i == current_mode_index)
		
func _on_select_pressed() -> void:
	for i in range(mode_buttons.size()):
		mode_buttons[i].visible = (i == current_mode_index)
		
	selectmode.visible = false
	
func _on_back_to_lobby_pressed() -> void:
	current_mode_index = 0
	selectmode.visible = false

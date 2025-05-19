extends HBoxContainer

@onready var characters := {
	"ballerina": $"../../PlayerCharacters/Ballerina_p2",
	"sahur": $"../../PlayerCharacters/Sahur_p2"
}

func _ready():
	for button in get_children():
		if button is TextureButton:
			# Match character by button name or meta
			var character_id = button.name.replace("P2_Character", "").to_int()
			var character_name = _get_character_name(character_id)
			button.pressed.connect(_on_character_selected.bind(character_name))

func _get_character_name(id: int) -> String:
	# Map index to actual character keys in `characters` dictionary
	match id:
		1: return "sahur"
		2: return "ballerina"
		# Add more as needed
		_: return ""

func _on_character_selected(character_id: String) -> void:
	for id in characters:
		characters[id].visible = (id == character_id)

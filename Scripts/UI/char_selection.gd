extends HBoxContainer

@onready var characters := {
	"sahur": $"../Characters/Sahur",
	"ballerina": $"../Characters/Ballerina",
	"tralalero": $"../Characters/Tralalero",
	"crocodilo": $"../Characters/Crocodilo",
	"chimpanzini": $"../Characters/Chimpanzini"
}

func _ready():
	# Set default if none saved yet
	if PLAYER_DATA.current_character == "":
		PLAYER_DATA.current_character = "sahur"
	
	# Show saved/default character
	_show_character(PLAYER_DATA.current_character)

	# Connect button signals
	for button in get_children():
		if button is TextureButton:
			var character_id = button.name.replace("Char", "").to_int()
			var character_name = _get_character_name(character_id)
			button.pressed.connect(_on_character_selected.bind(character_name))

func _get_character_name(id: int) -> String:
	match id:
		1: return "sahur"
		2: return "ballerina"
		3: return "tralalero"
		4: return "crocodilo"
		5: return "chimpanzini"
		_: return "sahur"  # fallback

func _on_character_selected(character_id: String) -> void:
	CharacterButtonClick.play_button_click()
	_show_character(character_id)
	PLAYER_DATA.current_character = character_id

func _show_character(character_id: String) -> void:
	for id in characters:
		characters[id].visible = (id == character_id)
		

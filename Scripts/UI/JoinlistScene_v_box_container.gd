extends VBoxContainer
@onready var lobby_buttons := get_children().filter(func(n): return n is TextureButton)
@onready var join_button := $"../../../Join"  # Adjust the path to your actual Join button

func _ready():
	for button in lobby_buttons:
		button.toggled.connect(_on_lobby_toggled)
	_update_join_button()

func _on_lobby_toggled(_pressed):
	_update_join_button()

func _update_join_button():
	# Check if any lobby is currently selected
	var any_selected = lobby_buttons.any(func(btn): return btn.button_pressed)
	join_button.disabled = not any_selected

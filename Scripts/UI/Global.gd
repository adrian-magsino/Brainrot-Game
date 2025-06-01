extends Node

var total_kills = 0
var player_name = ""
var current_character = ""

func save_game():
	var save_data = {
		"total_kills": total_kills,
		"player_name": player_name,
		"current_character": current_character
	}
	var file = FileAccess.open("user://save_data.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_game():
	if FileAccess.file_exists("user://save_data.json"):
		var file = FileAccess.open("user://save_data.json", FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if typeof(data) == TYPE_DICTIONARY:
			total_kills = data.get("total_kills", 0)
			player_name = data.get("player_name", "")
			current_character = data.get("current_character", "")
		file.close()

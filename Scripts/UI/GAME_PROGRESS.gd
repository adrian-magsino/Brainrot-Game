extends Node

var level_completed = {
	"lvl1": false,
	"lvl2": false,
	"lvl3": true,
	"lvl4": true,
	"lvl5": true,
	"lvl6": true,
	"lvl7": true,
	"lvl8": true,
	"lvl9": true,
	"lvl10": true
}

func save_progress():
	var file = FileAccess.open("user://game_progress.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(level_completed))
	file.close()

func load_progress():
	if FileAccess.file_exists("user://game_progress.json"):
		var file = FileAccess.open("user://game_progress.json", FileAccess.READ)
		var loaded_data = JSON.parse_string(file.get_as_text())
		if typeof(loaded_data) == TYPE_DICTIONARY:
			level_completed = loaded_data
		file.close()

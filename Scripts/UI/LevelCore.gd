extends Node

var level_completed = {
	"lvl1": false,
	"lvl2": false,
	"lvl3": false,
	"lvl4": false,
	"lvl5": false,
	"lvl6": false,
	"lvl7": false,
	"lvl8": false,
	"lvl9": false,
	"lvl10": false
}

func save_progress():
	var file = FileAccess.open("user://level_progress.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(level_completed))
	file.close()

func load_progress():
	if FileAccess.file_exists("user://level_progress.json"):
		var file = FileAccess.open("user://level_progress.json", FileAccess.READ)
		var loaded_data = JSON.parse_string(file.get_as_text())
		if typeof(loaded_data) == TYPE_DICTIONARY:
			level_completed = loaded_data
		file.close()

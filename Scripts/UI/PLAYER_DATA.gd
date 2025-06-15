extends Node

var total_kills = 0
var player_name = ""
var current_character = ""

var audio_settings = {
	"Master": {"volume": 1.0, "muted": false, "pressed": false},
	"Music": {"volume": 1.0, "muted": false, "pressed": false},
	"SFX": {"volume": 1.0, "muted": false, "pressed": false}
}
func save_game():
	var save_data = {
		"total_kills": total_kills,
		"player_name": player_name,
		"current_character": current_character,
		"audio_settings": audio_settings
	}
	var file = FileAccess.open("user://save_data.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("SAVED PLAYER DATA")
	
func apply_saved_audio_settings():
	for bus_name in audio_settings.keys():
		var settings = audio_settings[bus_name]
		if typeof(settings) == TYPE_DICTIONARY:
			var volume = settings.get("volume", 1.0)
			var muted = settings.get("muted", false)
			var bus_index = AudioServer.get_bus_index(bus_name)

			if muted:
				AudioServer.set_bus_volume_db(bus_index, linear_to_db(0.0))
			else:
				AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume))

			
func load_game():
	if FileAccess.file_exists("user://save_data.json"):
		var file = FileAccess.open("user://save_data.json", FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if typeof(data) == TYPE_DICTIONARY:
			total_kills = data.get("total_kills", 0)
			player_name = data.get("player_name", "")
			current_character = data.get("current_character", "")
			
			var saved_audio = data.get("audio_settings", null)
			if saved_audio and typeof(saved_audio) == TYPE_DICTIONARY:
				audio_settings = saved_audio
		file.close()
		print("LOADED PLAYER DATA")

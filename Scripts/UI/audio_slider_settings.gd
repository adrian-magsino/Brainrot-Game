extends Control

@onready var audio_name_lbl: Label = $TextContainer/Audio_Name_Lbl
@onready var h_slider: HSlider = $TextContainer/HSlider
@onready var sound_button: TextureButton = $TextContainer/SoundButton

@export_enum("Master", "Music", "SFX") var bus_name : String

var bus_index: int = 0
var is_muted := false
var last_volume: float = 1.0  # Default to max

func _ready():
	h_slider.value_changed.connect(on_value_changed)
	sound_button.pressed.connect(on_mute_toggled)
	get_bus_by_index()
	set_name_label_text()
	sync_with_saved_data()

func set_name_label_text() -> void:
	audio_name_lbl.text = str(bus_name) 

func get_bus_by_index() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)

func set_slider_value() -> void:
	var current_db = AudioServer.get_bus_volume_db(bus_index)
	var linear = db_to_linear(current_db)
	h_slider.value = linear
	last_volume = linear  # Sync on start

func on_value_changed(value: float) -> void:
	if is_muted:
		return  # Ignore volume changes when muted
	
	last_volume = value
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
		
	PLAYER_DATA.audio_settings[bus_name]["volume"] = value

func on_mute_toggled() -> void:
	is_muted = not is_muted

	if is_muted:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(0.0))
		h_slider.value = 0.0
		h_slider.editable = false
	else:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(last_volume))
		h_slider.value = last_volume
		h_slider.editable = true

	# Update PLAYER_DATA audio settings
	PLAYER_DATA.audio_settings[bus_name]["muted"] = is_muted
	PLAYER_DATA.audio_settings[bus_name]["pressed"] = is_muted

func sync_with_saved_data():
	var settings = PLAYER_DATA.audio_settings.get(bus_name, null)
	if settings:
		last_volume = settings.get("volume", 1.0)
		is_muted = settings.get("muted", false)
		h_slider.editable = not is_muted
		h_slider.value = 0.0 if is_muted else last_volume
		sound_button.set_pressed_no_signal(is_muted)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(h_slider.value))

extends Control

@onready var game_time_label: Label = $HBoxContainer/GameTimeLabel
@onready var ammo_label: Label = $"../PlayerControls/Switch Gun/AmmoLabel"

@onready var reload_progress_bar: TextureProgressBar = $"../PlayerControls/Reload Gun/ReloadProgress"
#@onready var reload_bar_label: Label = $ReloadProgress/ReloadBarLabel
@onready var current_gun_icon: TextureRect = $"../PlayerControls/Switch Gun/CurrentGunIcon"
@onready var current_gun_label: Label = $"../PlayerControls/Switch Gun/CurrentGunLabel"






func update_timer_label(time_string: String):
	game_time_label.text = "Time: " + time_string
	
func update_ammo(current_mag: int, current_total_ammo: int):
	ammo_label.text = "Ammo: %d / %d" % [current_mag, current_total_ammo]

func start_reload_bar(duration: float):
	#var progress_bar = $ReloadProgress
	#var progress_label = progress_bar.get_node("ReloadBarLabel")
	
	reload_progress_bar.visible = true
	#progress_label.visible = true
	#progress_label.text = "RELOADING..."
	reload_progress_bar.value = 0
	reload_progress_bar.max_value = duration
	
	
	#Animate the progress bar 
	var tween = create_tween()
	tween.tween_property(reload_progress_bar, "value", duration, duration)
	tween.connect("finished", Callable(self, "on_reload_bar_complete"))
	
func on_reload_bar_complete():
	reload_progress_bar.visible = false
	#reload_bar_label.visible = false
	
func reset_display():
	ammo_label.text = "Ammo: -- / --"
	reload_progress_bar.visible = false
	#reload_bar_label.visible = false
	current_gun_icon.texture = null
	current_gun_label.text = ""
	

func update_current_gun(gun: Node):
	var gun_sprite: Sprite2D = gun.get_node("Sprite2D")
	
	var texture = gun_sprite.texture
	var texture_size = texture.get_size()
	var icon_size = Vector2(32, 32)
	if gun:
		current_gun_icon.texture = texture
		current_gun_icon.custom_minimum_size = icon_size
		current_gun_label.text = gun.gun_name
		
	else:
		current_gun_icon.texture = null
		current_gun_label.text = ""

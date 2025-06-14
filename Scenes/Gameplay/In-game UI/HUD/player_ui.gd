extends Control

@onready var game_time_label: Label = $GameTimeLabel


func update_timer_label(time_string: String):
	game_time_label.text = "Time: " + time_string
	
func update_ammo(current_mag: int, current_total_ammo: int):
	$AmmoLabel.text = "Ammo: %d / %d" % [current_mag, current_total_ammo]

func start_reload_bar(duration: float):
	var progress_bar = $ReloadProgress
	var progress_label = progress_bar.get_node("ReloadBarLabel")
	
	progress_bar.visible = true
	progress_label.visible = true
	progress_label.text = "RELOADING..."
	progress_bar.value = 0
	progress_bar.max_value = duration
	
	
	#Animate the progress bar 
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", duration, duration)
	tween.connect("finished", Callable(self, "on_reload_bar_complete"))
	
func on_reload_bar_complete():
	$ReloadProgress.visible = false
	$ReloadProgress/ReloadBarLabel.visible = false
	
func reset_display():
	$AmmoLabel.text = "Ammo: -- / --"
	$ReloadProgress.visible = false
	$ReloadProgress/ReloadBarLabel.visible = false
	$GunDisplay/Panel/CurrentGunIcon.texture = null
	$GunDisplay/Panel/CurrentGunLabel.text = ""
	

func update_current_gun(gun: Node):
	var gun_sprite: Sprite2D = gun.get_node("Sprite2D")
	
	var texture = gun_sprite.texture
	var texture_size = texture.get_size()
	var icon_size = Vector2(32, 32)
	if gun:
		$"GunDisplay/Switch Gun/CurrentGunIcon".texture = texture
		$"GunDisplay/Switch Gun/CurrentGunIcon".custom_minimum_size = icon_size
		$"GunDisplay/Switch Gun/CurrentGunLabel".text = gun.gun_name
		
	else:
		$"GunDisplay/Switch Gun/CurrentGunIcon".texture = null
		$"GunDisplay/Switch Gun/CurrentGunLabel".text = ""

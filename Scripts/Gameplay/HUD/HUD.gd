extends CanvasLayer

func update_ammo(current_mag: int, total_ammo: int):
	$AmmoLabel.text = "Ammo: %d / %d" % [current_mag, total_ammo]
	
	
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
	
func reset_hud():
	$AmmoLabel.text = "Ammo: -- / --"
	$ReloadProgress.visible = false
	$ReloadProgress/ReloadBarLabel.visible = false

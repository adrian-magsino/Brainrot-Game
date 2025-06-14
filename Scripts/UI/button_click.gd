extends Node

var button_click_sound = preload("res://Game Assets/Audio/Downloaded Audio Resources(Not Final Audio)/SFX/ButtonClick.mp3")

func play_button_click():
	var player = AudioStreamPlayer.new()
	player.stream = button_click_sound
	player.bus = "SFX"  # Make sure "SFX" exists in your audio buses
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)  # Auto-cleanup

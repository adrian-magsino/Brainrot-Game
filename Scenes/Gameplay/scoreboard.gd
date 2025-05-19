# Scoreboard.gd
extends Control

class_name Scoreboard

@onready var container = $VBoxContainer
@export var player_row_scene: PackedScene

func update_scoreboard():
	
	print("SCOREBOARD UPDATED")
	print($"..".players)
	# Clear existing rows
	for child in container.get_children():
		child.queue_free()
	
	# Sort players by score descending
	var sorted_players = $"..".players.duplicate()
	sorted_players.sort_custom(func(a, b): return a.player_score > b.player_score)
	
	# Add a row for each player
	for player in sorted_players:
		var row = player_row_scene.instantiate()
		row.get_node("PlayerName").text = player.player_name
		row.get_node("ScoreLabel").text = str(player.player_score)
		row.get_node("DeathLabel").text = str(player.player_deaths)
		container.add_child(row)
		
		print("PlayerName: ", player.player_name)
		print("ScoreLabel: ", str(player.player_score))
		print("DeathLabel: ", str(player.player_deaths))

	visible = true

func toggle_visibility():
	visible = not visible

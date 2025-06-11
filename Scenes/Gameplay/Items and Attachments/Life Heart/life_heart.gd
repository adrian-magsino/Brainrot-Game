extends Node2D

@export var life_amount = 1

func on_picked_up(player: Player):
	add_life_to_player(player)
	
func add_life_to_player(player: Player):
	if player and player.player_lives > 0:
		player.player_lives += life_amount
		player.update_player_lives()
		

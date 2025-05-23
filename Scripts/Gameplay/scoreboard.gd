# Scoreboard.gd
extends CanvasLayer

class_name Scoreboard

@onready var name_label_p1 = $VBoxContainer/Player1Score/PlayerName
@onready var score_label_p1 = $VBoxContainer/Player1Score/ScoreLabel
@onready var deaths_label_p1 = $VBoxContainer/Player1Score/DeathCountLabel

@onready var name_label_p2 = $VBoxContainer/Player2Score/PlayerName
@onready var score_label_p2 = $VBoxContainer/Player2Score/ScoreLabel
@onready var deaths_label_p2 = $VBoxContainer/Player2Score/DeathCountLabel

func update_scoreboard(peer_id: int, name: String, score: int, deaths: int):
	if peer_id == 1:
		name_label_p1.text = "PLAYER" + name
		score_label_p1.text = "SCORE: " + str(score)
		deaths_label_p1.text = "DEATHS: " + str(deaths)
		
	else:
		name_label_p2.text = "PLAYER" + str(name)
		score_label_p2.text = "SCORE: " + str(score)
		deaths_label_p2.text = "DEATHS: " + str(deaths)

func toggle_visibility():
	visible = not visible

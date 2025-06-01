extends Node2D
class_name Level

@onready var control_node = get_node("Control")
@onready var score_label = control_node.get_node("HUD/ScoreLabel")

var enemies_killed: int = 0


func register_enemy_kill(attacker: Node) -> void:
	if attacker.is_in_group("player"):
		enemies_killed += 1
		score_label.text = "KILLS: %d" % [enemies_killed]
		print("Enemies killed: ", enemies_killed)

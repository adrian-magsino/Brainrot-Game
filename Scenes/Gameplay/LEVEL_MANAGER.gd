extends Node2D
class_name Level_Manager

@onready var HUD = get_node("HUD")
@onready var score_label = HUD.get_node("GameUI/ScoreLabel")
@onready var victory_panel = HUD.get_node("VictoryPanel")
@onready var total_kills_label = victory_panel.get_node("TotalKillsLabel")
@onready var message_label = victory_panel.get_node("Message")

var enemies_killed: int = 0
var level_cleared: bool = false

func register_enemy_kill(attacker: Node) -> void:
	if attacker.is_in_group("player"):
		enemies_killed += 1
		score_label.text = "KILLS: %d" % enemies_killed
		print("Enemies killed: ", enemies_killed)

func game_victory():
	level_cleared = true
	pause_level()
	victory_panel.visible = true
	total_kills_label.text = "Enemies killed: %d" % enemies_killed
	message_label.text = "Level Cleared!"  
	
func pause_level():
	for node in get_tree().get_nodes_in_group("pauseable"):
		node.process_mode = Node.PROCESS_MODE_DISABLED

func unpause_level():
	for node in get_tree().get_nodes_in_group("pauseable"):
		node.process_mode = Node.PROCESS_MODE_INHERIT

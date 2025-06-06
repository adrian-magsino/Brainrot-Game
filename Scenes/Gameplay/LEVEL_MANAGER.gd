extends Node2D
class_name Level_Manager

@onready var HUD = get_node("HUD")
@onready var score_label = HUD.get_node("GameUI/ScoreLabel")
@onready var player_lives_label = HUD.get_node("GameUI/PlayerLivesLabel")
@onready var victory_panel = HUD.get_node("GameResults/VictoryPanel")
@onready var defeat_panel = HUD.get_node("GameResults/DefeatPanel")

@export var player_lives: int = 1

var enemies_killed: int = 0
var level_cleared: bool = false

func _ready() -> void:
	update_player_lives()
	
func update_player_lives():
	player_lives_label.text = "LIVES: %d" % player_lives
	
func register_enemy_kill(attacker: Node) -> void:
	if attacker.is_in_group("player"):
		enemies_killed += 1
		score_label.text = "KILLS: %d" % enemies_killed
		print("Enemies killed: ", enemies_killed)

func game_victory():
	var total_kills_label = victory_panel.get_node("Scoreboard/TotalKillsLabel")
	var message_label = victory_panel.get_node("Message")
	level_cleared = true
	pause_level()
	victory_panel.visible = true
	total_kills_label.text = "Enemies killed: %d" % enemies_killed
	message_label.text = "Level Cleared!"  

func game_defeat():
	var total_kills_label = defeat_panel.get_node("Scoreboard/TotalKillsLabel")
	var message_label = defeat_panel.get_node("Message")
	
	level_cleared = false
	pause_level()
	defeat_panel.visible = true
	total_kills_label.text = "Enemies killed: %d" % enemies_killed
	message_label.text = "GAME OVER \n SKILL ISSUE BRO"  
	
func pause_level():
	for node in get_tree().get_nodes_in_group("pauseable"):
		node.process_mode = Node.PROCESS_MODE_DISABLED

func unpause_level():
	for node in get_tree().get_nodes_in_group("pauseable"):
		node.process_mode = Node.PROCESS_MODE_INHERIT

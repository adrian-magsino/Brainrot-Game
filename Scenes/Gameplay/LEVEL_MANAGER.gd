extends Node2D
class_name Level_Manager

@onready var HUD = get_node("HUD")
@onready var game_ui = HUD.get_node("GameUI")
@onready var score_label = HUD.get_node("GameUI/ScoreLabel")
@onready var player_lives_label = HUD.get_node("GameUI/PlayerLivesImage/PlayerLivesLabel")
@onready var victory_panel = HUD.get_node("GameResults/VictoryPanel")
@onready var defeat_panel = HUD.get_node("GameResults/DefeatPanel")
@onready var PLAYER = get_node("PLAYER")

#@export var player_lives: int = 1

var game_time := 0.0
var formatted_time = ""
var enemies_killed: int = 0
var level_cleared: bool = false

func _ready() -> void:
	PLAYER.update_player_lives()

	
func _process(delta):
	game_time += delta
	update_game_time_display()
	
func update_game_time_display():
	var minutes = int(game_time) / 60
	var seconds = int(game_time) % 60
	formatted_time = "%02d:%02d" % [minutes, seconds]

	game_ui.update_timer_label(formatted_time)
	

	
func register_enemy_kill(attacker: Node) -> void:
	if attacker.is_in_group("player"):
		enemies_killed += 1
		score_label.text = "KILLS: %d" % enemies_killed
		print("Enemies killed: ", enemies_killed)

func game_victory():
	var message_label = victory_panel.get_node("Message")
	var total_kills_label = victory_panel.get_node("Scoreboard/TotalKillsLabel")
	var total_game_time_label = victory_panel.get_node("Scoreboard/TotalGameTimeLabel")
	var player_deaths_label = victory_panel.get_node("Scoreboard/PlayerDeathsLabel")
	
	level_cleared = true
	pause_level()
	victory_panel.visible = true
	message_label.text = "LEVEL CLEARED!"  
	total_kills_label.text = "ENEMIES KILLED: %d" % enemies_killed
	player_deaths_label.text = "DEATHS: %d" % PLAYER.player_deaths
	total_game_time_label.text = "GAME TIME: " + formatted_time
	
func game_defeat():
	var message_label = defeat_panel.get_node("Message")
	var total_kills_label = defeat_panel.get_node("Scoreboard/TotalKillsLabel")
	var total_game_time_label = victory_panel.get_node("Scoreboard/TotalGameTimeLabel")
	var player_deaths_label = victory_panel.get_node("Scoreboard/PlayerDeathsLabel")
	
	level_cleared = false
	pause_level()
	defeat_panel.visible = true
	message_label.text = "GAME OVER \n SKILL ISSUE BRO"  
	total_kills_label.text = "ENEMIES KILLED: %d" % enemies_killed
	player_deaths_label.text = "DEATHS: %d" % PLAYER.player_deaths
	total_game_time_label.text = "GAME TIME: " + formatted_time
	
func pause_level():
	for node in get_tree().get_nodes_in_group("pauseable"):
		node.process_mode = Node.PROCESS_MODE_DISABLED
	set_process(false)

func unpause_level():
	for node in get_tree().get_nodes_in_group("pauseable"):
		node.process_mode = Node.PROCESS_MODE_INHERIT
	set_process(true)

extends Node2D
class_name Level_Manager

@onready var HUD = get_node("HUD")
@onready var game_ui = HUD.get_node("GameUI")
@onready var score_label = HUD.get_node("GameUI/HBoxContainer/ScoreLabel")
@onready var player_lives_label = HUD.get_node("GameUI/HBoxContainer/PlayerLivesImage/PlayerLivesLabel")
@onready var game_results_container = HUD.get_node("GameResults")
@onready var victory_panel = game_results_container.get_node("VictoryPanel")
@onready var defeat_panel = game_results_container.get_node("DefeatPanel")
@onready var PLAYER = get_node("PLAYER")
@onready var objectives_display = HUD.get_node("ObjectivesContainer")
@export var level_objectives: String = "CLEAR THE LEVEL"

#@export var player_lives: int = 1

var game_time := 0.0
var formatted_time = ""
var enemies_killed: int = 0
var level_cleared: bool = false

func _ready() -> void:
	Bgm.stop()
	PLAYER.update_player_lives()
	update_objectives_display(level_objectives)
	
func _process(delta):
	game_time += delta
	update_game_time_display()

func update_objectives_display(text: String):
	var objectives_label = objectives_display.get_node("Objectives")
	objectives_label.text = text
	objectives_display.show_objectives()

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
	game_results_container.visible = true
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
	game_results_container.visible = true
	defeat_panel.visible = true
	message_label.text = "YOU LOST! \n SKILL ISSUE"  
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

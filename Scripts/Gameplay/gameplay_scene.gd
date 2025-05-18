extends Node2D

@onready var dummy_scene = preload("res://Scenes/Gameplay/Dummies/dummy.tscn")
@onready var spawners = []
@export var max_dummies := 3
@export var player_scene: PackedScene

var active_dummies := []

@onready var multiplayer_ui = $MultiplayerUI/Multiplayer
var peer = ENetMultiplayerPeer.new()

var players: Array[Player] = []

func _on_host_button_pressed() -> void:
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	print("Successfully Hosted a Game")
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer " + str(pid) + " has joined the game!")
			add_player(pid)
	)
	add_player(multiplayer.get_unique_id()) #Host
	
	multiplayer_ui.hide()
func _on_join_button_pressed() -> void:
	peer.create_client("localhost", 135)
	multiplayer.multiplayer_peer = peer
	multiplayer_ui.hide()
func add_player(pid):
	var player = player_scene.instantiate()
	player.name = str(pid)
	add_child(player)
	
func _ready():
	if multiplayer.is_server():
		spawners = get_tree().get_nodes_in_group("dummy_spawners")
		spawn_initial_dummies()
	
func spawn_initial_dummies():
	var available_spawners = spawners.filter(func(spawner):
		return spawner.initial_spawn and not spawner.is_occupied	
	)
	var count = min(max_dummies, available_spawners.size())
	for i in count:
		var spawner = available_spawners[i]
		spawn_dummy_at_spawner(spawner)
	
func spawn_dummy_at_spawner(spawner):
	if multiplayer.is_server():
		spawn_dummy_networked.rpc(spawner.get_path()) # Call on all peers


func _on_dummy_died(spawner_node, _position):
	if not multiplayer.is_server():
		return # Only server handles respawning
		
	await get_tree().create_timer(2.0).timeout #respawn timer
	spawner_node.is_occupied = false
	spawn_dummy_at_free_spawner()
	
func spawn_dummy_at_free_spawner():
	var free_spawners = spawners.filter(func(spawner):
		return not spawner.is_occupied
	)
	if free_spawners.is_empty():
		print("No available spawners!")
		return
	var chosen_spawner = free_spawners[randi() % free_spawners.size()]
	spawn_dummy_networked.rpc(chosen_spawner.get_path())

	
@rpc("call_local")
func spawn_dummy_networked(spawner_path: NodePath):
	var spawner = get_node(spawner_path)
	var dummy = dummy_scene.instantiate()
	dummy.spawner_node = spawner
	add_child(dummy)
	dummy.set_multiplayer_authority(1) # Host is the authority
	dummy.global_position = spawner.global_position
	dummy.connect("died", Callable(self, "_on_dummy_died"))
	spawner.is_occupied = true
	active_dummies.append(dummy)

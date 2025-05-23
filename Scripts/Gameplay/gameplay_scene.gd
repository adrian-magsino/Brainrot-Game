extends Node2D

@onready var scoreboard = $Control/Scoreboard
@onready var dummy_scene = preload("res://Scenes/Gameplay/Dummies/dummy.tscn")
@onready var spawners = []
@export var max_dummies := 3

var game_started := false

var active_dummies := []

func _ready():
	
	start_game()
	
func start_game():
	game_started = true

	spawners = get_tree().get_nodes_in_group("dummy_spawners")
	spawn_initial_dummies()

func spawn_initial_dummies():
	var available_spawners = spawners.filter(func(spawner):
		return spawner.initial_spawn and not spawner.is_occupied	
	)
	var count = min(max_dummies, available_spawners.size())
	for i in count:
		var spawner = available_spawners[i]
		spawn_dummy_at_free_spawner()


func _on_dummy_died(spawner_node, _position):
		
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
	var dummy = dummy_scene.instantiate()
	dummy.spawner_node = chosen_spawner
	add_child(dummy)
	dummy.set_multiplayer_authority(1) # Host is the authority
	dummy.global_position = chosen_spawner.global_position
	dummy.connect("died", Callable(self, "_on_dummy_died"))
	chosen_spawner.is_occupied = true
	active_dummies.append(dummy)

	

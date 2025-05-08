extends Node2D

@onready var dummy_scene = preload("res://Scenes/dummy.tscn")
@onready var spawners = []
@export var max_dummies := 3

var active_dummies := []


func _ready():
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
	var dummy = dummy_scene.instantiate()
	dummy.spawner_node = spawner
	add_child(dummy)
	dummy.global_position = spawner.global_position
	dummy.connect("died", Callable(self, "_on_dummy_died"))
	spawner.is_occupied = true

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
	spawn_dummy_at_spawner(chosen_spawner)

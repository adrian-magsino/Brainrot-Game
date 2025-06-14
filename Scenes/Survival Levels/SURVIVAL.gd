extends Level_Manager
class_name SurvivalMode

# Declare all enemy scene paths (ideally use an EnemyRegistry for large games)
var all_enemy_scene_paths = [
	"res://Scenes/Gameplay/Enemies/enemy bot 1/enemy_bot.tscn",
	"res://Scenes/Gameplay/Enemies/fast enemy bot/fast_enemy_bot.tscn",
	"res://Scenes/Gameplay/Enemies/klee enemy bot/klee_enemy_bot.tscn",
]

var difficulty_stages = [
	{ "time": 0, "interval": 10.0, "spawn_count": 1, "max_enemies": 3, "enemy_types": ["normal_enemy"] as Array[String] },
	{ "time": 30, "interval": 7.0, "spawn_count": 2, "max_enemies": 5, "enemy_types": ["normal_enemy", "fast_enemy"] as Array[String] },
	{ "time": 60, "interval": 1.0, "spawn_count": 3, "max_enemies": 10, "enemy_types": ["normal_enemy", "fast_enemy", "special"] as Array[String]},
	#{ "time": 360, "interval": 5.0, "spawn_count": 4, "max_enemies": 8, "enemy_types": ["normal_enemy", "ranged_enemy", "elite"] as Array[String], "spawn_boss": true }
]

var current_difficulty_stage = 0
var next_dynamic_stage_time = 90  # After the last manual stage ends at 60s
var dynamic_stage_interval = 30   # Every 30 seconds afterward

func _ready() -> void:
	PLAYER.update_player_lives()
	level_objectives = "SURVIVE\nSTAGE %d" % (current_difficulty_stage+1)
	update_objectives_display(level_objectives)
	await get_tree().process_frame
	print("SURVIVAL READY")
	change_difficulty_stage(0)


	
func _process(delta):
	super._process(delta)
	
	if current_difficulty_stage < difficulty_stages.size() - 1:
		var next_stage = difficulty_stages[current_difficulty_stage + 1]
		if game_time >= next_stage.time:
			current_difficulty_stage += 1
			change_difficulty_stage(current_difficulty_stage)
			
	elif game_time >= next_dynamic_stage_time:
		current_difficulty_stage += 1
		change_difficulty_stage(current_difficulty_stage, true)
		next_dynamic_stage_time += dynamic_stage_interval

func change_difficulty_stage(stage_index: int, is_infinite := false):
	if is_infinite:
		increase_infinite_stage(stage_index)
	else:
		var stage = difficulty_stages[stage_index]
		print("Applying difficulty stage:", stage_index, "with tags:", stage.enemy_types)
		for spawner in get_tree().get_nodes_in_group("enemy_spawner"):
			spawner.spawn_interval = stage.interval
			spawner.spawn_count = stage.spawn_count
			spawner.max_enemies = stage.max_enemies
			spawner.enemy_scenes = load_enemy_scenes_by_tags(stage.enemy_types)
			print("Spawner:", spawner.name, "assigned enemies:", spawner.enemy_scenes.size())
			if !spawner.enemy_scenes.is_empty():
				spawner.spawn_timer.wait_time = stage.interval
				spawner.spawn_timer.start()
				
	print("DIFFICULTY HAS BEEN INCREASED")
	level_objectives = "SURVIVE\nSTAGE %d" % (current_difficulty_stage+1)
	update_objectives_display(level_objectives)


func increase_infinite_stage(stage_index: int):
	# Dynamically scale values after predefined stages
	var base_stage = difficulty_stages[-1]  # Use last defined stage as base
	var spawn_count = base_stage.spawn_count + int((stage_index - difficulty_stages.size()) / 1)
	var max_enemies = base_stage.max_enemies + int((stage_index - difficulty_stages.size()) * 1.5)
	var interval = max(0.5, base_stage.interval)  # Optional: clamp to prevent too-fast spawning
	
	print("Applying DYNAMIC difficulty stage:", stage_index)
	print("NEW SPAWN COUNT: ", spawn_count)
	print("NEW MAX ENEMIES: ", max_enemies )
	print("NEW INTERVAL: ", interval)

	for spawner in get_tree().get_nodes_in_group("enemy_spawner"):
		spawner.spawn_interval = interval
		spawner.spawn_count = spawn_count
		spawner.max_enemies = max_enemies
		spawner.enemy_scenes = load_enemy_scenes_by_tags(["normal_enemy", "fast_enemy", "special"])  # or choose based on your logic
		print("Spawner:", spawner.name, "assigned enemies:", spawner.enemy_scenes.size())
		if !spawner.enemy_scenes.is_empty():
			spawner.spawn_timer.wait_time = interval
			spawner.spawn_timer.start()
# ✅ New metadata-based loader
func load_enemy_scenes_by_tags(tags: Array[String]) -> Array[PackedScene]:
	var result: Array[PackedScene] = []

	for path in all_enemy_scene_paths:
		var scene = load(path)
		if scene is PackedScene:
			var instance = scene.instantiate()
			if instance is Node and "enemy_type" in instance and tags.has(instance.enemy_type):
				result.append(scene)
			instance.queue_free()
	
	return result

func game_victory():
	pass

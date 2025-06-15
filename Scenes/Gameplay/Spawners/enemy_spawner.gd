extends Area2D

@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_interval: float = 10.0
@export var max_enemies: int = 3
@export var spawn_count: int = 2 #number of enemies spawned every session
@export var spawn_area_extents: Vector2 = Vector2(100, 100)

var active_enemies: Array[Node] = []

@onready var spawn_timer: Timer = $SpawnTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var color_rect: ColorRect = $CollisionShape2D/ColorRect

func _ready():
	add_to_group("pauseable") #This node will pause along with the game
	if collision_shape.shape is RectangleShape2D:
		# Duplicate the shape so each spawner gets a unique instance
		var shape = collision_shape.shape.duplicate()
		shape.extents = spawn_area_extents / 2
		collision_shape.shape = shape
		#print("CUSTOM EXTENTS SET TO:", shape.extents)
		
		color_rect.size = shape.extents * 2
		color_rect.position = -shape.extents
		color_rect.color = Color(1, 0, 0, 0.3) # semi-transparent red
		if GAME_DEBUG_SCRIPT.game_debug_mode == false:
			color_rect.visible = false
		
	#print("ENEMY SPAWN TIMER SET")
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	if enemy_scenes.is_empty():
		print("ENEMY SPAWNER IS EMPTY")
		
		
	else:
		spawn_timer.start()
	
		
func _on_spawn_timer_timeout():
	var available_slots = max_enemies - active_enemies.size()
	#print("GUN SPAWNER TIMEOUT")
	if available_slots <= 0:
		#print("ENEMY MAX LIMIT REACHED")
		# Don't spawn more enemies yet
		spawn_timer.start()
		return
	
	var spawn_this_cycle = min(spawn_count, available_slots)
	for i in spawn_this_cycle:
		spawn_enemy()

	spawn_timer.start()


func spawn_enemy():
	if enemy_scenes.is_empty():
		return

	var enemy_scene = enemy_scenes.pick_random()
	var enemy = enemy_scene.instantiate()
	#enemy.target_player = get_parent().get_node("PLAYER")
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		enemy.target_player = player
	else:
		#print("Player not found!")
		return
	
	var shape: RectangleShape2D = collision_shape.shape
	var jitter = 100.0
	var spawn_position = Vector2(
		randf_range(-shape.extents.x, shape.extents.x),
		randf_range(-shape.extents.y, shape.extents.y)
	)
	enemy.global_position = spawn_position
	add_child(enemy, true) # replicate ownership if needed
	#print("ENEMY HAS BEEN SPAWNED: ", enemy.get_path())
	active_enemies.append(enemy)
	if enemy.has_signal("tree_exited"):
		enemy.tree_exited.connect(_on_enemy_removed.bind(enemy))


func _on_enemy_removed(enemy: Node):
	#print("Enemy removed:", enemy.name)
	active_enemies.erase(enemy)

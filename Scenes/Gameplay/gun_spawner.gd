extends Area2D

@export var gun_scenes: Array[PackedScene] = []
@export var spawn_interval: float = 10.0
@export var max_guns: int = 3
@export var spawn_area_extents: Vector2 = Vector2(100, 100)

var current_guns: Array[Node] = []

@onready var spawn_timer: Timer = $SpawnTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var color_rect: ColorRect = $CollisionShape2D/ColorRect

func _ready():
	if gun_scenes.is_empty():
		print("GUN SPAWNER IS EMPTY")
		return
	if collision_shape.shape is RectangleShape2D:
		# Duplicate the shape so each spawner gets a unique instance
		var shape = collision_shape.shape.duplicate()
		shape.extents = spawn_area_extents / 2
		collision_shape.shape = shape
		print("CUSTOM EXTENTS SET TO:", shape.extents)
		
		color_rect.size = shape.extents * 2
		color_rect.position = -shape.extents
		color_rect.color = Color(1, 0, 0, 0.3) # semi-transparent red
		
	if is_multiplayer_authority():
		print("GUN SPAWN TIMER SET")
		spawn_timer.wait_time = spawn_interval
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
		spawn_timer.start()

func _on_spawn_timer_timeout():
	print("GUN SPAWNER TIMEOUT")
	if current_guns.size() >= max_guns:
		print("MAX LIMIT REACHED")
		# Don't spawn more guns yet
		spawn_timer.start()
		return
	
	spawn_gun()
	spawn_timer.start()


func spawn_gun():
	if not multiplayer.is_server():
		return
	
	if gun_scenes.is_empty():
		return

	var gun_index = randi() % gun_scenes.size()
	var shape: RectangleShape2D = collision_shape.shape
	var jitter = 100.0
	var spawn_position = Vector2(
		randf_range(-shape.extents.x, shape.extents.x),
		randf_range(-shape.extents.y, shape.extents.y)
	)
	print("SPAWNER EXTENTS: ", -shape.extents.x, shape.extents.x, -shape.extents.y, shape.extents.y)
	print("SPAWNED GUN IN: ", spawn_position)
	sync_spawn_gun.rpc(spawn_position, gun_index)

	
@rpc("call_local")
func sync_spawn_gun(spawn_position: Vector2, gun_index: int):
	if gun_index < 0 or gun_index >= gun_scenes.size():
		print("Invalid gun index received")
		return

	var gun_scene = gun_scenes[gun_index]
	var gun = gun_scene.instantiate()
	var global_spawn_position = spawn_position
	#var global_spawn_position = global_position + spawn_position
	#var global_spawn_position = to_global(spawn_position)
	gun.global_position = global_spawn_position
	
	add_child(gun, true) # replicate ownership if needed
	
	current_guns.append(gun)
	if gun.has_signal("tree_exited"):
		gun.tree_exited.connect(_on_gun_removed.bind(gun))


func _on_gun_removed(gun: Node):
	print("GUN REMOVED FROM SPAWNER")
	current_guns.erase(gun)

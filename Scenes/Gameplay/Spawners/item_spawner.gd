extends Area2D

@export var item_scenes: Array[PackedScene] = []
@export var spawn_interval: float = 10.0
@export var max_items: int = 3
@export var spawn_area_extents: Vector2 = Vector2(100, 100)

var current_items: Array[Node] = []

@onready var spawn_timer: Timer = $SpawnTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var color_rect: ColorRect = $CollisionShape2D/ColorRect

func _ready():
	add_to_group("pauseable") #This node will pause along with the game
	if item_scenes.is_empty():
		print("ITEM SPAWNER IS EMPTY")
		return
	if collision_shape.shape is RectangleShape2D:
		# Duplicate the shape so each spawner gets a unique instance
		var shape = collision_shape.shape.duplicate()
		shape.extents = spawn_area_extents / 2
		collision_shape.shape = shape
		#print("CUSTOM EXTENTS SET TO:", shape.extents)
		
		color_rect.size = shape.extents * 2
		color_rect.position = -shape.extents
		color_rect.color = Color(0, 1, 0, 0.3) # semi-transparent green
		if GAME_DEBUG_SCRIPT.game_debug_mode == false:
			color_rect.visible = false
			
	#print("ITEM SPAWN TIMER SET")
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	
		
func _on_spawn_timer_timeout():

	if current_items.size() >= max_items:
		print("ITEM MAX LIMIT REACHED")
		# Don't spawn more items yet
		spawn_timer.start()
		return
	
	spawn_items()
	spawn_timer.start()


func spawn_items():
	if item_scenes.is_empty():
		return

	var item_scene = item_scenes.pick_random()
	var item = item_scene.instantiate()
	
	var shape: RectangleShape2D = collision_shape.shape
	var jitter = 100.0
	var spawn_position = Vector2(
		randf_range(-shape.extents.x, shape.extents.x),
		randf_range(-shape.extents.y, shape.extents.y)
	)
	#print("SPAWNER EXTENTS: ", -shape.extents.x, shape.extents.x, -shape.extents.y, shape.extents.y)
	#print("SPAWNED GUN IN: ", spawn_position)
	item.global_position = spawn_position
	add_child(item, true) 
	print("ITEM HAS BEEN SPAWNED: ", item.get_path())
	current_items.append(item)
	if item.has_signal("tree_exited"):
		item.tree_exited.connect(_on_item_removed.bind(item))


func _on_item_removed(item: Node):
	#print("ITEM REMOVED FROM SPAWNER")
	current_items.erase(item)

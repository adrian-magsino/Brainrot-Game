extends Area2D

@export var speed: float = 300.0
@export var damage: int = 10

var direction: Vector2 = Vector2.ZERO
var distance_traveled := 0.0
var max_distance := 500.0
var pass_through_walls := false

func initialize(dir: Vector2, max_dist: float, can_pass_walls: bool):
	direction = dir.normalized()
	max_distance = max_dist
	pass_through_walls = can_pass_walls
	
func _process(delta):
	var movement = direction * speed * delta
	position += movement
	distance_traveled += movement.length()
	
	if distance_traveled >= max_distance:
		queue_free()

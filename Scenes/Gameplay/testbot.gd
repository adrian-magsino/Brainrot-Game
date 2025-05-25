extends CharacterBody2D

var speed = 100
var accel = 7

@export var player: Node2D
@onready var nav: NavigationAgent2D = $NavigationAgent2D

func _physics_process(delta: float) -> void:
	
	var direction = Vector3()
	
	nav.target_position = player.global_position
	
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	#velocity = velocity.lerp(direction * speed, accel * delta)
	velocity = direction * speed
	
	move_and_slide()

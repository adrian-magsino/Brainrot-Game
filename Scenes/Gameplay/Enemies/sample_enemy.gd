extends CharacterBody2D

const speed = 100

@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

func _physics_process(delta: float) -> void:
	var direction = Vector3()
	direction = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = direction * speed
	
	move_and_slide()
	#nav_agent.target_position = player.global_position
	#velocity = velocity.lerp(direction * speed, accel * delta)
	
	
func make_path() -> void:
	nav_agent.target_position = player.global_position
		
func _on_timer_timeout() -> void:
	make_path()

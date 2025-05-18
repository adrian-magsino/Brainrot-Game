#extends CharacterBody2D
extends "res://Scripts/Gameplay/Shared_Scripts/Damageable.gd"


var  spawner_node: Node = null

#signal died(spawner_node: Node, position: Vector2)

func _ready():
	current_health = max_health
	update_health_bar()
		
@rpc("call_local")
func _networked_die():
	emit_signal("died", spawner_node, global_position)
	queue_free()

func die():
	if is_multiplayer_authority():
		_networked_die.rpc() # Call on all peers

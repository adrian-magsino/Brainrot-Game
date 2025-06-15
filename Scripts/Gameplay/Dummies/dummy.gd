#extends CharacterBody2D
extends "res://Scripts/Gameplay/Shared_Scripts/EntityHealthManager.gd"


var  spawner_node: Node = null

#signal died(spawner_node: Node, position: Vector2)

func _ready():
	current_health = max_health
	update_health_bar()


func die(damager: Node):
	emit_signal("died", spawner_node, global_position)
	queue_free()

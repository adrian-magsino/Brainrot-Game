extends CharacterBody2D

@export var max_health: int = 100

var current_health: int
var  spawner_node: Node = null

signal died(spawner_node: Node, position: Vector2)

func _ready():
	current_health = max_health
	update_health_bar()
	
func take_damage(amount: int):
	current_health -= amount
	current_health = max(current_health, 0)
	update_health_bar()
	if current_health <= 0:
		die()
		
func update_health_bar():
	if has_node("HealthBar"):
		var bar = $HealthBar
		bar.max_value = max_health
		bar.value = current_health
		
func die():
	emit_signal("died", spawner_node, global_position)
	queue_free()

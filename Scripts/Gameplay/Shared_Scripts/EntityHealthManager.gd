# EntityHealthManager.gd
extends CharacterBody2D
class_name DamageableEntity

@export var max_health: int = 100
var current_health: int
var is_dead: bool = false

signal died

func _ready():
	current_health = max_health
	update_health_bar()

func take_damage(amount: int, damager: Node):
	if not is_multiplayer_authority():
		return
	
	current_health -= amount
	current_health = max(current_health, 0)
	update_health_bar()

	
	if current_health <= 0:
		die(damager)

func update_health_bar():
	if has_node("HealthBar"):
		var bar = $HealthBar
		bar.max_value = max_health
		bar.value = current_health

func die(damager: Node):
	if is_dead:
		return
	is_dead = true
	emit_signal("died")
	
	queue_free()

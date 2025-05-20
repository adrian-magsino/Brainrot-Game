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

#@rpc("any_peer", "call_local")
func take_damage(amount: int, damager: Node):
	if not is_multiplayer_authority():
		return
	
	current_health -= amount
	current_health = max(current_health, 0)
	update_health_bar()
	update_health_bar_networked.rpc(current_health)
	
	if current_health <= 0:
		die(damager)

@rpc("call_local")
func update_health_bar_networked(new_health: int):
	current_health = new_health
	update_health_bar()

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

# EntityHealthManager.gd
extends CharacterBody2D
class_name DamageableEntity

@onready var health_bar = $HealthBar
@onready var hide_healthbar_timer = get_node_or_null("HealthBar/HideHealthBarTimer")

@export var max_health: int = 100
var current_health: int
var is_dead: bool = false

signal died

func _ready():
	current_health = max_health
	update_health_bar()
	health_bar.visible = false
	if hide_healthbar_timer:
		hide_healthbar_timer.timeout.connect(_on_hide_timer_timeout)

func take_damage(amount: int, damager: Node):
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
		if hide_healthbar_timer:
			health_bar.visible = true
			hide_healthbar_timer.start()
func _on_hide_timer_timeout():
	if hide_healthbar_timer:
		health_bar.visible = false
	
func die(damager: Node):
	if is_dead:
		return
	is_dead = true
	emit_signal("died")
	
	queue_free()

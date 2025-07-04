# Damageable.gd
extends StaticBody2D
#class_name Destructible

@onready var health_bar = $HealthBar
@onready var hide_healthbar_timer = $HealthBar/HideHealthBarTimer
@export var max_health: int = 100
var current_health: int
var is_destroyed: bool = false

signal destroyed

func _ready():
	current_health = max_health
	update_health_bar()
	health_bar.visible = false
	hide_healthbar_timer.timeout.connect(_on_hide_timer_timeout)


func take_damage(amount: int, damager: Node):
	if not is_multiplayer_authority():
		return

	current_health -= amount
	current_health = max(current_health, 0)
	update_health_bar()
	
	health_bar.visible = true
	hide_healthbar_timer.start()
	
	if current_health <= 0:
		call_deferred("destroy", damager) 
	
func update_health_bar():
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_bar.visible = true
	hide_healthbar_timer.start()
func _on_hide_timer_timeout():
	health_bar.visible = false
	
func destroy(damager: Node):
	if is_destroyed:
		return
	is_destroyed = true
	emit_signal("destroyed")
	queue_free()
	

extends Node2D
class_name HealthComponent

@export var MAX_HEALTH := 10.0
var health: float

@onready var health_bar = get_node_or_null("HealthBar")
@onready var hide_healthbar_timer = get_node_or_null("HealthBar/HideHealthBarTimer")

func _ready() -> void:
	health = MAX_HEALTH
	update_health_bar()
	if hide_healthbar_timer:		
		health_bar.visible = false
		hide_healthbar_timer.timeout.connect(_on_hide_timer_timeout)

func reset_health():
	health = MAX_HEALTH
	update_health_bar()
	
func damage(attack: AttackComponent):
	health -= attack.attack_damage
	update_health_bar()
	if health <= 0:
		if get_parent().has_method("die"):
			get_parent().die(attack)
		if get_parent().has_method("destroy"):
			get_parent().destroy(attack)
		#get_parent().queue_free()
	
func update_health_bar():
	if health_bar:
		health_bar.max_value = MAX_HEALTH
		health_bar.value = health
		if hide_healthbar_timer:
			health_bar.visible = true
			hide_healthbar_timer.start()
			
func _on_hide_timer_timeout():
	if hide_healthbar_timer:
		health_bar.visible = false

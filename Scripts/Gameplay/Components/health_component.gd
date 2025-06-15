extends Node2D
class_name HealthComponent

@export var MAX_HEALTH := 10.0
@export var can_regenerate := false
@export_range(0.0, 1.0) var regeneration_percent := 0.10 # 10% of max health per tick
@export var regeneration_interval := 1.0 # seconds between regen ticks
@export var regeneration_delay := 3.0 # seconds after taking damage before regen starts

var health: float

@onready var health_bar = get_node_or_null("HealthBar")
@onready var hide_healthbar_timer = get_node_or_null("HealthBar/HideHealthBarTimer")

# Regen timers
var regen_delay_timer: Timer
var regen_tick_timer: Timer

func _ready() -> void:
	health = MAX_HEALTH
	update_health_bar()

	if hide_healthbar_timer:
		health_bar.visible = false
		hide_healthbar_timer.timeout.connect(_on_hide_timer_timeout)

	# Initialize and add regen timers
	regen_delay_timer = Timer.new()
	regen_delay_timer.wait_time = regeneration_delay
	regen_delay_timer.one_shot = true
	regen_delay_timer.timeout.connect(_on_regen_delay_timeout)
	add_child(regen_delay_timer)

	regen_tick_timer = Timer.new()
	regen_tick_timer.wait_time = regeneration_interval
	regen_tick_timer.timeout.connect(_on_regen_tick_timeout)
	add_child(regen_tick_timer)

func reset_health():
	health = MAX_HEALTH
	update_health_bar()
	stop_regeneration()

func damage(attack: AttackComponent):
	health -= attack.attack_damage
	update_health_bar()

	stop_regeneration()
	regen_delay_timer.start() # restart regen delay on new damage

	if health <= 0:
		if get_parent().has_method("die"):
			get_parent().die(attack)
		elif get_parent().has_method("destroy"):
			get_parent().destroy(attack)
		else:
			get_parent().queue_free()

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

func _on_regen_delay_timeout():
	if can_regenerate and health < MAX_HEALTH:
		regen_tick_timer.start()

func _on_regen_tick_timeout():
	if not can_regenerate:
		stop_regeneration()
		return
	if health < MAX_HEALTH:
		var amount = MAX_HEALTH * regeneration_percent
		health = min(health + amount, MAX_HEALTH)
		update_health_bar()
	else:
		stop_regeneration()

func stop_regeneration():
	regen_delay_timer.stop()
	regen_tick_timer.stop()

extends CharacterBody2D
class_name EnemyBot

@export var move_speed: float = 200.0
@export var bot_name: String = "ENEMY BOT"
@export var attack_cooldown: float = 1.0
@export var can_destroy_objects: bool = false

@onready var target_player = get_parent().get_node("PLAYER")
@onready var nav_agent := $NavigationAgent2D
@onready var attack_cooldown_timer := $AttackCooldownTimer
@onready var attack_area: Area2D = $AttackArea
@onready var sfx_bot: AudioStreamPlayer2D = $SFX_bot
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_component: AttackComponent = $AttackComponent

var can_attack: bool = true
var damageable_in_range: Node = null

func _ready() -> void:
	sfx_bot.play()
	health_component.update_health_bar()
	attack_cooldown_timer.wait_time = attack_cooldown

func _physics_process(delta: float) -> void:
	var direction = nav_agent.get_next_path_position() - global_position
	velocity = direction.normalized() * move_speed
	move_and_slide()

func make_path() -> void:
	nav_agent.target_position = target_player.global_position

func _on_timer_timeout() -> void:
	make_path()

func _on_attack_area_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var target = area.get_parent()
		if target == self:
			return  # Don't damage self
		if target is EnemyBot:
			return  # Don't damage other enemies
		if target.has_node("HealthComponent"):
			damageable_in_range = target
			if can_attack:
				_attack_target()

func _on_attack_area_area_exited(area: Area2D) -> void:
	if area is HitboxComponent and area.get_parent() == damageable_in_range:
		damageable_in_range = null

func _on_damage_cooldown_timer_timeout() -> void:
	can_attack = true
	if damageable_in_range:
		_attack_target()

func _attack_target() -> void:
	if damageable_in_range and can_attack:
		var hitbox = damageable_in_range.get_node_or_null("HitboxComponent")
		if hitbox:
			hitbox.take_damage(attack_component)
			can_attack = false
			attack_cooldown_timer.start()

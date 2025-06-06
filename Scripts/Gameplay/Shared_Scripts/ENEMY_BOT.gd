extends CharacterBody2D
class_name EnemyBot

@export var move_speed: float = 200.0
@export var bot_name: String = "ENEMY BOT"
@export var attack_cooldown: float = 1.0
@export var can_destroy_objects: bool = false
@onready var nav_agent := $NavigationAgent2D
@onready var attack_cooldown_timer := $AttackCooldownTimer
@onready var attack_area: Area2D = $AttackArea
@onready var sfx_bot: AudioStreamPlayer2D = $SFX_bot
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_component: AttackComponent = $AttackComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var target_player: Node2D
var can_attack: bool = true
var is_attacking: bool = false
var damageable_in_range: Node = null
var is_dead: bool = false
	
func _ready() -> void:
	add_to_group("pauseable") #This node will pause along with the game
	target_player = get_tree().get_first_node_in_group("player")
	sfx_bot.play()
	health_component.update_health_bar()
	attack_cooldown_timer.wait_time = attack_cooldown
	animated_sprite_2d.animation_finished.connect(_on_AnimatedSprite2D_animation_finished)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if is_attacking:
		velocity = Vector2.ZERO
	else:
		var direction = nav_agent.get_next_path_position() - global_position
		velocity = direction.normalized() * move_speed
		if velocity.length() > 0:
			animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("idle") # Optional if you have an idle animation

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
				animated_sprite_2d.play("attack")

func _on_attack_area_area_exited(area: Area2D) -> void:
	if area is HitboxComponent and area.get_parent() == damageable_in_range:
		damageable_in_range = null

func _on_damage_cooldown_timer_timeout() -> void:
	can_attack = true
	if damageable_in_range:
		_attack_target()
		animated_sprite_2d.play("attack")

func _attack_target() -> void:
	if damageable_in_range and can_attack:
		var hitbox = damageable_in_range.get_node_or_null("HitboxComponent")
		if hitbox:
			hitbox.take_damage(attack_component)
			can_attack = false
			is_attacking = true
			animated_sprite_2d.play("attack")
			attack_cooldown_timer.start()
			
func die(attack: AttackComponent):
	if is_dead:
		return
	is_dead = true
	
	if attack.attacker and attack.attacker.is_in_group("player"):
		var level_node = get_tree().current_scene
		if level_node.has_method("register_enemy_kill"):
			level_node.register_enemy_kill(attack.attacker)
	queue_free()
	
func _on_AnimatedSprite2D_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack":
		is_attacking = false

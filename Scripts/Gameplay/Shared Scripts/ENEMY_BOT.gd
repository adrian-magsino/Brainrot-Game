extends CharacterBody2D
class_name EnemyBot

@export_enum("normal_enemy", "fast_enemy", "ranged_enemy", "special", "elite", "boss")
var enemy_type: String

@export var move_speed: float = 200.0
@export var bot_name: String = "ENEMY BOT"
@export var attack_cooldown: float = 1.0
@export var can_destroy_objects: bool = false

@onready var sfx_bot: AudioStreamPlayer2D = $SFX_bot

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

#Components
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_component: AttackComponent = $AttackComponent
@onready var bloody_death_animation: Node2D = $BloodyDeathAnimation

@onready var attack_area: Area2D = $AttackArea
@onready var attack_cooldown_timer := $AttackCooldownTimer
@onready var nav_agent := $NavigationAgent2D

var target_player: Node2D
var can_attack: bool = true
var is_attacking: bool = false
var damageable_in_range: Node = null
var is_dead: bool = false

@onready var object_timer := Timer.new()

var is_near_object: bool = false
var pending_object_target: Node = null
	
func _ready() -> void:
	add_to_group("pauseable") #This node will pause along with the game
	target_player = get_tree().get_first_node_in_group("player")
	sfx_bot.play()
	health_component.update_health_bar()
	attack_cooldown_timer.wait_time = attack_cooldown
	
	if animated_sprite_2d.sprite_frames.has_animation("attack"):
		animated_sprite_2d.animation_finished.connect(_on_AnimatedSprite2D_animation_finished)

	object_timer.wait_time = 2.0
	object_timer.one_shot = true
	object_timer.connect("timeout", Callable(self, "_on_object_timer_timeout"))
	add_child(object_timer)
	
func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if is_attacking:
		velocity = Vector2.ZERO
	else:
		var direction = nav_agent.get_next_path_position() - global_position
		velocity = direction.normalized() * move_speed
		
		if direction.x != 0:
			animated_sprite_2d.flip_h = direction.x < 0
			
		if velocity.length() > 0:
			animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("idle") 

	move_and_slide()

func make_path() -> void:
	nav_agent.target_position = target_player.global_position

func _on_timer_timeout() -> void:
	make_path()

func _on_attack_area_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var target = area.get_parent()
		if target == self or target is EnemyBot:
			return

		if target == target_player:
			damageable_in_range = target
			object_timer.stop()
			pending_object_target = null
			if can_attack:
				_attack_target()
		elif can_destroy_objects and target.has_node("HealthComponent"):
			pending_object_target = target
			object_timer.start()


func _on_attack_area_area_exited(area: Area2D) -> void:
	if area is HitboxComponent:
		var target = area.get_parent()
		if target == damageable_in_range:
			damageable_in_range = null
		if target == pending_object_target:
			pending_object_target = null
			object_timer.stop()
func _on_object_timer_timeout() -> void:
	if pending_object_target and not damageable_in_range:
		damageable_in_range = pending_object_target
		if can_attack:
			_attack_target()


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
			is_attacking = true
			attack_cooldown_timer.start()
			
			if animated_sprite_2d.sprite_frames.has_animation("attack"):
				animated_sprite_2d.play("attack")
			else:
				is_attacking = false  # No animation, reset immediately

			
func die(attack: AttackComponent):
	if is_dead:
		return
	is_dead = true
	
	bloody_death_animation.play_death_animation()
	if attack.attacker and attack.attacker.is_in_group("player"):
		var level_node = get_tree().current_scene
		if level_node.has_method("register_enemy_kill"):
			level_node.register_enemy_kill(attack.attacker)
	queue_free()
	
func _on_AnimatedSprite2D_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack":
		is_attacking = false

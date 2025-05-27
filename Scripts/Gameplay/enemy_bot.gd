extends CharacterBody2D

@export var move_speed: float = 200.0
@export var bot_name: String = "ENEMY BOT"
@export var attack_cooldown: float = 1.0
@export var can_destroy_objects: bool = false

@onready var target_player = get_parent().get_node("PLAYER")
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var attack_cooldown_timer := $AttackCooldownTimer
@onready var attack_area: Area2D = $AttackArea
@onready var sfx_bot: AudioStreamPlayer2D = $SFX_bot
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_component: AttackComponent = $AttackComponent

var can_attack: bool = true
var player_in_range: Player = null

func _ready() -> void:
	sfx_bot.play()
	health_component.update_health_bar()
	attack_cooldown_timer.wait_time = attack_cooldown

func _physics_process(delta: float) -> void:
	var direction = Vector3()
	direction = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = direction * move_speed
	
	move_and_slide()
func make_path() -> void:
	nav_agent.target_position = target_player.global_position
		
func _on_timer_timeout() -> void:
	make_path()

func _on_attack_area_area_entered(area: Area2D) -> void:
	if area is HitboxComponent and area.get_parent() != self:
		var player = area.get_parent()
		if player is Player and not player.is_dead:
			player_in_range = player
			if can_attack:
				_attack_player()
			#player_in_range = area.get_parent()
			#_attack()
	
func _on_attack_area_area_exited(area: Area2D) -> void:
	if area is HitboxComponent and area.get_parent() == player_in_range:
		player_in_range = null

func _on_damage_cooldown_timer_timeout() -> void:
	can_attack = true
	if player_in_range:
		_attack_player()

func _attack_player():
	if player_in_range and can_attack:
		player_in_range.get_node("HitboxComponent").take_damage(attack_component)
		can_attack = false
		attack_cooldown_timer.start()
	

extends DamageableEntity

@export var move_speed: float = 200.0
@export var bot_name: String = "ENEMY BOT"
@export var damage: int = 10
@export var damage_cooldown: float = 1.0

@onready var target_player = get_parent().get_node("PLAYER")
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var dammage_cooldown_timer := $DamageCooldownTimer
@onready var damage_area := $DamageArea
@onready var sfx_bot: AudioStreamPlayer2D = $SFX_bot

var can_damage: bool = true
var player_in_range: DamageableEntity = null

func _ready() -> void:
	sfx_bot.play()
	current_health = max_health
	update_health_bar()
	health_bar.visible = false
	if hide_healthbar_timer:
		hide_healthbar_timer.timeout.connect(_on_hide_timer_timeout)
	dammage_cooldown_timer.wait_time = damage_cooldown

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

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = body
		deal_damage()

func _on_damage_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null

func _on_damage_cooldown_timer_timeout() -> void:
	can_damage = true
	deal_damage()
	
func deal_damage():
	if can_damage and player_in_range and not player_in_range.is_dead:
		print("DEAL DAMAGE")
		player_in_range.take_damage(damage, self)
		can_damage = false
		dammage_cooldown_timer.start()

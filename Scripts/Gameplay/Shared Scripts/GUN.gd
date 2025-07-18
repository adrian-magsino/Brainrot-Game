extends Area2D
class_name Gun

@export var gun_name: String = "SampleGun"
@onready var item_name = gun_name
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.05
@export var range: float = 500.0
@export var max_ammo: int = 100
@export var magazine_capacity: int = 50
@export var reload_time: float = 1.5
@export var zoom_distance: Array[float] = [1.0]
#Zoom Distance Mapping = [1.0, 0.9, 0.8, 0.7, 0.6] # Level 1, 2, 3, 4, etc.

#Special Conditions
@export var bullet_pass_through_walls: bool = false
@export var ricochet: bool = false #bullets bounce
@export var self_damage_bullets: bool = false #bullets damage the shooter
@export var laser_sight_equipped: bool = false

#Bullet Spread Mode
@export var bullet_spread: bool = false
@export var bullet_spread_amount: int = 3
@export var spread_angle_step_deg: float = 5.0

@onready var icon_texture: Texture2D = $Sprite2D.texture #Get gun sprite as texture
@onready var sfx_shoot: AudioStreamPlayer2D = $SFX_shoot

#PICKUP/DROP MECHANICS
var is_picked_up: bool = false
var owner_player: Node = null

#SHOOTING
var last_shot_time := 0.0
var current_magazine: int
var current_total_ammo: int
var is_reloading: bool = false

#SIGNALS
signal ammo_changed(current_mag, current_total_ammo) #Update ammo label
signal reload_started(duration)

func _process(delta):
	if is_picked_up:
		last_shot_time += delta
		if owner_player and $BulletPos.has_node("LaserSight"):
			var laser_sight = $BulletPos.get_node("LaserSight")
			laser_sight.activate(owner_player)
			
func shoot(direction: Vector2):
	if is_reloading or last_shot_time < fire_rate:
		return
	if current_magazine <= 0:
		start_reload()
		return

	last_shot_time = 0.0

	if bullet_spread:
		shoot_bullet_spread(direction)
	else:
		shoot_single_bullet(direction)

	emit_signal("ammo_changed", current_magazine, current_total_ammo)
	if current_magazine == 0:
		start_reload()

func spawn_bullet(position: Vector2, direction: Vector2, rotation: float):
	var bullet_instance = bullet_scene.instantiate()
	bullet_instance.global_position = position
	bullet_instance.rotation = rotation

	if bullet_instance.has_method("initialize"):
		bullet_instance.initialize(
			direction,
			range,
			bullet_pass_through_walls,
			owner_player,
			self_damage_bullets
		)
		
	get_tree().current_scene.add_child(bullet_instance)

func shoot_single_bullet(direction: Vector2):
	if current_magazine <= 0:
		return

	current_magazine -= 1

	var bullet_pos = $BulletPos.global_position
	var angle = direction.angle()

	spawn_bullet(bullet_pos, direction, angle)
	sfx_shoot.play()
func shoot_bullet_spread(direction: Vector2):
	var bullets_to_fire = bullet_spread_amount
	var angle_step = deg_to_rad(spread_angle_step_deg)
	var base_angle = direction.angle()

	for i in range(bullets_to_fire):
		if current_magazine <= 0:
			break
		current_magazine -= 1

		var spread_index = i - (bullets_to_fire - 1) / 2
		var spread_angle = base_angle + (spread_index * angle_step)
		var spread_direction = Vector2.RIGHT.rotated(spread_angle)
		var bullet_pos = $BulletPos.global_position

		spawn_bullet(bullet_pos, spread_direction, spread_angle)
		sfx_shoot.play()
func start_reload():
	if is_reloading or current_magazine == magazine_capacity or current_total_ammo == 0:
		return
	is_reloading = true
	ReloadSound.play()
	emit_signal("reload_started", reload_time)
	get_tree().create_timer(reload_time).connect("timeout", Callable(self, "_on_reload_timeout"))
	emit_signal("ammo_changed", current_magazine, current_total_ammo)
	
func _on_reload_timeout():
	var needed = magazine_capacity - current_magazine
	var to_reload = min(needed, current_total_ammo)
	current_magazine += to_reload
	current_total_ammo -= to_reload
	is_reloading = false

func _ready():
	current_magazine = magazine_capacity
	current_total_ammo = max_ammo
	
func can_be_picked_up() -> bool:
	return !is_picked_up
	
func pick_up(parent_node: Node2D):
	is_picked_up = true
	owner_player = parent_node.get_parent()
	get_node("CollisionShape2D").disabled = true
	self.get_parent().remove_child(self)
	parent_node.add_child(self)
	self.position = Vector2.ZERO  # reset relative position
	
func drop(position: Vector2, parent_node: Node):
	is_picked_up = false
	owner_player = null

	# Defer reparenting and collision enabling to avoid physics flush conflict
	call_deferred("_deferred_drop", position, parent_node)
	
func _deferred_drop(position: Vector2, parent_node: Node):
	
	if self.get_parent():
		self.get_parent().remove_child(self)
	parent_node.add_child(self)
	self.global_position = position
	get_node("CollisionShape2D").disabled = false
	




			

	
	

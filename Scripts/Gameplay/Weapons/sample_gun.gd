extends Area2D

@export var gun_name: String = "SampleGun"
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.05
@export var range: float = 500.0
@export var max_ammo: int = 100
@export var magazine_capacity: int = 50
@export var reload_time: float = 1.5
@export var bullet_pass_through_walls: bool = false
@export var self_damage_bullets: bool = false


#PICKUP/DROP MECHANICS
var is_picked_up: bool = false
var owner_player: Node = null

#SHOOTING
var last_shot_time := 0.0
var current_magazine := magazine_capacity
var total_ammo := max_ammo
var is_reloading: bool = false

#SIGNALS
signal ammo_changed(current_mag, total_ammo) #Update ammo label
signal reload_started(duration)

func _process(delta):
	if is_picked_up:
		last_shot_time += delta

func shoot(direction: Vector2):
	
	if is_reloading or last_shot_time < fire_rate: 
		return
		
	if current_magazine <= 0:
		start_reload()
		return
	last_shot_time = 0.0
	current_magazine -= 1
	emit_signal("ammo_changed", current_magazine, total_ammo)
	var bullet_instance = bullet_scene.instantiate()
	bullet_instance.global_position = $BulletPos.global_position
	bullet_instance.rotation = direction.angle()
	
	if bullet_instance.has_method("initialize"):
		print(self_damage_bullets)
		bullet_instance.initialize(direction, range, bullet_pass_through_walls, owner_player, self_damage_bullets)
	
	get_tree().current_scene.add_child(bullet_instance)
	
	if current_magazine == 0:
		start_reload()

func start_reload():
	if is_reloading or current_magazine == magazine_capacity or total_ammo == 0:
		return
	is_reloading = true
	emit_signal("reload_started", reload_time)
	get_tree().create_timer(reload_time).connect("timeout", Callable(self, "_on_reload_timeout"))
	emit_signal("ammo_changed", current_magazine, total_ammo)
func _on_reload_timeout():
	var needed = magazine_capacity - current_magazine
	var to_reload = min(needed, total_ammo)
	current_magazine += to_reload
	total_ammo -= to_reload
	is_reloading = false

func _ready():
	pass
	
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
	self.get_parent().remove_child(self)
	parent_node.add_child(self)
	self.global_position = position
	get_node("CollisionShape2D").set_deferred("disabled", false)
	

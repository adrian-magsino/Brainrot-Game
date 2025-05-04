extends Area2D

@export var gun_name: String = "SampleGun"
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.2
@export var range: float = 500.0
@export var max_ammo: int = 100
@export var magazine_capacity: int = 100
@export var reload_time: float = 1.5
@export var bullet_pass_through_walls: bool = false


#PICKUP/DROP MECHANICS

var is_picked_up: bool = false

#SHOOTING
var last_shot_time := 0.0
var current_magazine := magazine_capacity
var total_ammo := max_ammo

func _process(delta):
	if is_picked_up:
		last_shot_time += delta

func shoot(direction: Vector2):
	if last_shot_time < fire_rate or current_magazine <= 0:
		return
	
	last_shot_time = 0.0
	current_magazine -= 1
	
	var bullet_instance = bullet_scene.instantiate()
	bullet_instance.global_position = $BulletPos.global_position
	bullet_instance.rotation = direction.angle()
	
	if bullet_instance.has_method("initialize"):
		bullet_instance.initialize(direction, range, bullet_pass_through_walls)
	
	get_tree().current_scene.add_child(bullet_instance)

func _ready():
	pass
	
func pick_up(parent_node: Node2D):
	is_picked_up = true
	get_node("CollisionShape2D").disabled = true
	self.get_parent().remove_child(self)
	parent_node.add_child(self)
	self.position = Vector2.ZERO  # reset relative position

func drop(position: Vector2, parent_node: Node):
	is_picked_up = false
	self.get_parent().remove_child(self)
	parent_node.add_child(self)
	self.global_position = position
	get_node("CollisionShape2D").disabled = false
	

extends Area2D
class_name Bullet

@export var speed: float = 300.0
@export var can_damage_owner: bool = false 
@export var BulletParticle: PackedScene
#^^^change the value only if the initialize function is not being used
#^^^example: bullet traps

var direction: Vector2 = Vector2.ZERO
var distance_traveled := 0.0
var max_distance := 800.0
var pass_through_walls := false

var shooter: Node = null
var shooter_id: int

@onready var attack_component = $AttackComponent
@onready var bullet_light: PointLight2D = $BulletLight
@onready var surrounding_light: PointLight2D = $SurroundingLight
func _ready() -> void:
	bullet_light.visible = LightingManager.lights_enabled
	surrounding_light.visible = LightingManager.lights_enabled

func initialize(dir: Vector2, gun_range: float, can_pass_walls: bool, shooter_node: Node, allow_self_damage: bool = false):
	direction = dir.normalized()
	max_distance = gun_range
	pass_through_walls = can_pass_walls
	shooter = shooter_node
	can_damage_owner = allow_self_damage
	
	get_node("AttackComponent").attacker = shooter_node
	
func _process(delta):
	var movement = direction * speed * delta
	position += movement
	distance_traveled += movement.length()
	
	if distance_traveled >= max_distance:
		queue_free()
		
func _on_body_entered(body):
	
	if body == shooter and not can_damage_owner:
		return
		
	if body is TileMapLayer:
		hit_animation()
		queue_free()
		
func hit_animation():
	var _particle = BulletParticle.instantiate()
	_particle.position = global_position
	_particle.rotation = global_rotation
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)
	
func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		if area.get_parent() is Player and not can_damage_owner:
			return
		area.take_damage(attack_component)
		#print("DAMAGE: ", attack_component.attack_damage)
		#print("SHOOTER: ", attack_component.attacker)
		hit_animation()
		queue_free()

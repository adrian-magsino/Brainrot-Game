extends Area2D

@export var speed: float = 300.0
@export var damage: int = 10
@export var can_damage_owner: bool = false 
@export var BulletParticle: PackedScene
#^^^change the value only if the initialize function is not being used
#^^^example: bullet traps

var direction: Vector2 = Vector2.ZERO
var distance_traveled := 0.0
var max_distance := 500.0
var pass_through_walls := false

var owner_player: Node = null
var owner_player_id: int

func initialize(dir: Vector2, max_dist: float, can_pass_walls: bool, shooter: Node, allow_self_damage: bool = false):
	direction = dir.normalized()
	max_distance = max_dist
	pass_through_walls = can_pass_walls
	owner_player = shooter
	#owner_player_id = shooter_id
	can_damage_owner = allow_self_damage
	
func _process(delta):
	var movement = direction * speed * delta
	position += movement
	distance_traveled += movement.length()
	
	if distance_traveled >= max_distance:
		queue_free()
		
func _on_body_entered(body):
	
	if body == owner_player and not can_damage_owner:
		return
	
	#print("Hit: ", body.name)
	if body.has_node("CollisionShape2D"):
		if body.has_method("take_damage"):
			body.take_damage(damage, owner_player)
			#print("Damage!: ", body.name)
			#print("Damaged Body Path: ", body.get_path())
		hit_animation()
		queue_free()
	elif body is TileMapLayer:
		hit_animation()
		queue_free()
		
		
func hit_animation():
	var _particle = BulletParticle.instantiate()
	_particle.position = global_position
	_particle.rotation = global_rotation
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)
	
	
	
	

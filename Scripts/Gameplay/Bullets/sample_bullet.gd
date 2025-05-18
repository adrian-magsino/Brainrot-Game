extends Area2D

@export var speed: float = 300.0
@export var damage: int = 10
@export var can_damage_owner: bool = false 
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
	
	print("Hit: ", body.name)
	if body.has_method("take_damage"):
		var authority_id = body.get_multiplayer_authority()
		if body == owner_player and can_damage_owner:
			body.take_damage(damage)
		if authority_id != 0: # <- 0 is the invalid/default
			body.take_damage.rpc_id(authority_id, damage)
		else:
			body.take_damage(damage)
		print("Damage!: ", body.name)
		print("Damaged Body Path: ", body.get_path())
		queue_free()

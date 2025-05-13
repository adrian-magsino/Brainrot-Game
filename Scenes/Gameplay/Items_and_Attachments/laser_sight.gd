extends Area2D

@export var item_type: String = "attachment"

var range: float = 500
var is_active: bool = false
var owner_player: Node = null
var parent_gun: Node = null
var is_picked_up: bool = false

func _process(_delta):
	if is_active and owner_player:
		var aim_input = owner_player.get_aim_input()
		var direction = aim_input.get("direction", Vector2.ZERO)
		if direction.length() > 0.1:
			update_laser(direction)

func update_laser(direction: Vector2):
	var ray = $LaserRay
	var line = $LaserLine

	#rotation = direction.angle()
	ray.target_position = Vector2(range, 0)
	ray.force_raycast_update()

	var hit_pos = ray.target_position
	if ray.is_colliding():
		hit_pos = ray.to_local(ray.get_collision_point())

	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(hit_pos)
	line.visible = true

func activate(owner_ref: Node):
	owner_player = owner_ref
	is_active = true
	$LaserLine.visible = true
	$LaserRay.enabled = true

func deactivate():
	is_active = false
	$LaserLine.visible = false
	$LaserRay.enabled = false

func update_laser_sight(direction: Vector2):
	var laser_ray = $BulletPos/LaserRay
	var laser_line = $BulletPos/LaserLine
	
	
	
	laser_ray.target_position = Vector2(range, 0)
	laser_ray.force_raycast_update()
	
	var hit_position = laser_ray.target_position
	if laser_ray.is_colliding():
		hit_position = laser_ray.to_local(laser_ray.get_collision_point())
	
	laser_line.clear_points()
	laser_line.add_point(Vector2.ZERO)
	laser_line.add_point(hit_position)
	laser_line.visible = true

func can_be_picked_up() -> bool:
	return !is_picked_up
	
func pick_up(player: Node):
	is_picked_up = true
	owner_player = player

	var gun = player.get_held_gun()
	if gun and gun.has_method("replace_attachment"):
		gun.replace_attachment(self, player)

	$Sprite2D.visible = false
	activate(player)

func on_attach_to_gun(gun: Node, player: Node):
	parent_gun = gun
	owner_player = player

func drop(drop_position: Vector2 = Vector2.ZERO, parent_node: Node = null):
	is_picked_up = false
	is_active = false
	call_deferred("_deferred_drop", drop_position, parent_node)

func _deferred_drop(drop_position: Vector2, parent_node: Node):
	if get_parent():
		get_parent().remove_child(self)

	if parent_node:
		parent_node.add_child(self)
	else:
		# Fallback to the root if no parent_node was provided
		get_tree().root.add_child(self)

	global_position = drop_position
	owner_player = null
	parent_gun = null
	$Sprite2D.visible = true
	deactivate()

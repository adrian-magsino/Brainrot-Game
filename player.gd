extends CharacterBody2D

var score: int = 0

#components
@onready var sprite = $PlayerSprite

#physics
@export var move_speed: int = 200

#pickup mechanics
var held_gun: Node = null

	
func _physics_process(delta):
	
	#MOVEMENTS
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = input_vector * move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	
	
	
	#PICKUP/DROP MECHANICS
	if Input.is_action_just_pressed("pickup_or_drop"):
		pickup_or_drop_gun()
	
	#FLIP SPRITES HORIZONTALLY
	var aim_direction = get_aim_direction()
	if aim_direction.length() > 0.1:
		sprite.flip_h = aim_direction.x < 0
	elif input_vector.x != 0:
		sprite.flip_h = input_vector.x < 0
		#Flip gun sprite (by movement)
		if held_gun and held_gun.has_node("Sprite2D"):
			var gun_sprite = held_gun.get_node("Sprite2D")
			gun_sprite.flip_h = sprite.flip_h
			sprite.flip_h = gun_sprite.flip_h
			
	#AIMING
	if aim_direction.length() > 0.1 and held_gun:
		# Rotate the gun based on aim direction
		var angle = aim_direction.angle()
		held_gun.rotation = angle

		# Flip the gun sprite (through aiming)
		if held_gun.has_node("Sprite2D"):
			var gun_sprite = held_gun.get_node("Sprite2D")
			gun_sprite.flip_v = angle > PI/2 or angle < -PI/2

func pickup_or_drop_gun():
	var pickup_area = $PickupArea
	var overlapping = pickup_area.get_overlapping_areas()
	
	for area in overlapping:
		if area.has_method("pick_up") and !area.is_picked_up:
			if held_gun:
				print("Holding a gun")
				# Drop current gun before picking up the new one
				drop_gun()
			held_gun = area
			held_gun.pick_up($GunHolder)
			return
			
	#Drop gun
	if held_gun:
		drop_gun()
	

func drop_gun():
	if held_gun:
		held_gun.drop(self.global_position + Vector2(0, 16), get_tree().current_scene)
		held_gun = null
		
func get_aim_direction() -> Vector2:
	var aim_vector = Vector2.ZERO
	aim_vector.x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	aim_vector.y = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	return aim_vector.normalized()

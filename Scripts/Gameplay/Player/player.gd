extends CharacterBody2D

var score: int = 0

#components
@onready var sprite = $PlayerSprite
@onready var pickup_button = get_node("/root/GameplayScene/Control/TouchControls/Pickup Gun")

#physics
@export var move_speed: int = 200

#pickup mechanics
var held_gun: Node = null


var facing_left: bool = false #Sprite flipping

	
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
	
	update_pickup_button_visibility()
		
	
	#FLIP SPRITES HORIZONTALLY
	var aim_direction = get_aim_direction()
	var use_aiming = aim_direction.length() > 0.1
	if use_aiming:
		facing_left = aim_direction.x < 0 #aiming joystick
	elif input_vector.x != 0:
		facing_left = input_vector.x < 0 #movement joystick
	
	sprite.flip_h = facing_left #flip character sprite
	# Rotate the gun based on aim direction
	if held_gun:
		var gun_holder = held_gun.get_parent()
		# Flip the gun sprite through aiming
		if gun_holder and use_aiming:
			var angle = aim_direction.angle()
			var is_flipped = angle > PI/2 or angle < -PI/2		
			gun_holder.scale.x = -1 if is_flipped else 1 #Flip gun holder node
			held_gun.rotation = PI - angle if is_flipped else angle 
			
		#Flip the gun sprite by movement
		if gun_holder:
			gun_holder.scale.x = -1 if facing_left else 1
	
	#SHOOTING
	if use_aiming and Input.is_action_pressed("shoot"):
		if held_gun and held_gun.has_method("shoot"):
			held_gun.shoot(aim_direction)
	
	#RELOADING
	if Input.is_action_just_pressed("reload_gun") and held_gun:
		held_gun.start_reload()
		
	if held_gun:
		var hud = get_node("/root/GameplayScene/Control/HUD")
		hud.update_ammo(held_gun.current_magazine, held_gun.total_ammo)
		

func pickup_or_drop_gun():
	var pickup_area = $PickupArea
	var overlapping = pickup_area.get_overlapping_areas()
	
	for area in overlapping:
		if area.has_method("pick_up") and !area.is_picked_up:
			if held_gun:
				print("Holding a gun")
				# Drop current gun before picking up the new one
				drop_gun()
			equip_gun(area)
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


func _on_pickup_gun_pressed() -> void:
	if held_gun and held_gun.is_reloading: #Can't pickup guns while reloading
		return
	pickup_or_drop_gun()
	
func update_pickup_button_visibility():
	var pickup_area = $PickupArea
	var overlapping = pickup_area.get_overlapping_areas()
	var found_gun = false
	
	for area in overlapping:
		if area.has_method("pick_up") and !area.is_picked_up:
			found_gun = true
			break
			
	pickup_button.visible = found_gun


func _on_reload_gun_pressed() -> void:
	if held_gun:
		held_gun.start_reload()

func equip_gun(gun: Node):
	
	if gun.is_connected("ammo_changed", Callable(self, "_on_ammo_changed")):
		gun.disconnect("ammo_changed", Callable(self, "_on_ammo_changed"))
	if gun.is_connected("reload_started", Callable(self, "_on_reload_started")):
		gun.disconnect("reload_started", Callable(self, "_on_reload_started"))

	held_gun = gun
	held_gun.connect("ammo_changed", Callable(self, "_on_ammo_changed"))
	held_gun.connect("reload_started", Callable(self, "_on_reload_started"))

	
func _on_ammo_changed(current_mag, total_ammo):
	get_node("/root/GameplayScene/Control/HUD").update_ammo(current_mag, total_ammo)
	
func _on_reload_started(duration: float):
	get_node("/root/GameplayScene/Control/HUD").start_reload_bar(duration)

extends CharacterBody2D

var score: int = 0
@export var default_gun_scene: PackedScene
@onready var hud = get_node("/root/GameplayScene/Control/HUD")
# Components
@onready var sprite = $PlayerSprite
@onready var pickup_button = get_node("/root/GameplayScene/Control/TouchControls/Pickup Gun")
@onready var respawn_delay: float = 2.0

# Attributes
@export var move_speed: int = 200
@export var max_health: int = 100
var current_health: int
var is_dead: bool = false

# Inventory System
var gun_inventory: Array[Node] = [null, null] # Two gun slots
var current_gun_index: int = 0

var facing_left: bool = false # Sprite flipping

func _ready():
	current_health = max_health
	update_health_bar()
	set_default_gun()

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = input_vector * move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	if Input.is_action_just_pressed("pickup_or_drop"):
		pickup_or_drop_gun()
	if Input.is_action_just_pressed("switch_gun"):
		switch_gun()

	update_pickup_button_visibility()

	var aim_input = get_aim_input()
	var aim_direction = aim_input.direction
	var aim_strength = aim_input.strength
	var AIM_THRESHOLD = 0.2
	var SHOOT_THRESHOLD = 0.9
	var use_aiming = aim_strength >= AIM_THRESHOLD
	if use_aiming:
		facing_left = aim_direction.x < 0
	elif input_vector.x != 0:
		facing_left = input_vector.x < 0

	sprite.flip_h = facing_left
	var gun = get_held_gun()
	if gun:
		var gun_holder = gun.get_parent()
		if gun_holder and use_aiming:
			var angle = aim_direction.angle()
			var is_flipped = angle > PI/2 or angle < -PI/2
			gun_holder.scale.x = -1 if is_flipped else 1
			gun.rotation = PI - angle if is_flipped else angle
		if gun_holder:
			gun_holder.scale.x = -1 if facing_left else 1
		if aim_strength >= SHOOT_THRESHOLD and Input.is_action_pressed("shoot"):
			gun.shoot(aim_direction)
		if Input.is_action_just_pressed("reload_gun"):
			gun.start_reload()
		var hud = get_node("/root/GameplayScene/Control/HUD")
		hud.update_ammo(gun.current_magazine, gun.total_ammo)
		
func take_damage(amount: int):
	current_health -= amount
	current_health = max(current_health, 0)
	update_health_bar()
	if current_health <= 0:
		die()

func update_health_bar():
	if has_node("HealthBar"):
		var bar = $HealthBar
		bar.max_value = max_health
		bar.value = current_health

func die():
	if is_dead:
		return
	is_dead = true
	drop_guns_on_death()
	get_node("/root/GameplayScene/Control/HUD").reset_hud()
	visible = false
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(respawn_delay).timeout
	respawn()

func respawn():
	current_health = max_health
	update_health_bar()
	var spawn_points = get_tree().get_nodes_in_group("player_spawners")
	if spawn_points.size() > 0:
		var random_spawn = spawn_points[randi() % spawn_points.size()]
		global_position = random_spawn.global_position
	visible = true
	set_physics_process(true)
	$CollisionShape2D.disabled = false
	is_dead = false
	set_default_gun()

func get_aim_input() -> Dictionary:
	var aim_vector = Vector2(
		Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
		Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	)
	return {
		"direction": aim_vector.normalized(),
		"strength": aim_vector.length()
	}

func set_default_gun():
	if default_gun_scene and gun_inventory[0] == null and gun_inventory[1] == null:
		var default_gun = default_gun_scene.instantiate()
		get_tree().current_scene.add_child.call_deferred(default_gun)
		default_gun.global_position = global_position
		await default_gun.ready
		default_gun.pick_up($GunHolder)
		gun_inventory[0] = default_gun
		current_gun_index = 0
		equip_gun(default_gun)
		
func get_held_gun() -> Node:
	return gun_inventory[current_gun_index]

func switch_gun():
	if gun_inventory[0] != null and gun_inventory[1] != null:
		hide_gun_visual(get_held_gun())
		current_gun_index = 1 - current_gun_index
		show_gun_visual(get_held_gun())
		hud.update_current_gun(get_held_gun())
		
func hide_gun_visual(gun: Node):
	if gun:
		gun.visible = false
		gun.set_physics_process(false)

func show_gun_visual(gun: Node):
	if gun:
		gun.visible = true
		gun.set_physics_process(true)

func pickup_or_drop_gun():
	var pickup_area = $PickupArea
	var overlapping = pickup_area.get_overlapping_areas()
	for area in overlapping:
		if area.has_method("pick_up") and !area.is_picked_up:
			if gun_inventory[0] == null:
				gun_inventory[0] = area
				current_gun_index = 0
				equip_gun(area)
				area.pick_up($GunHolder)
				return
			elif gun_inventory[1] == null:
				gun_inventory[1] = area
				current_gun_index = 1
				equip_gun(area)
				area.pick_up($GunHolder)
				return
			else:
				drop_gun()
				gun_inventory[current_gun_index] = area
				equip_gun(area)
				area.pick_up($GunHolder)
				return
	if get_held_gun():
		drop_gun()

func pickup_item():
	var pickup_area = $PickupArea
	var overlapping = pickup_area.get_overlapping_areas()
	for area in overlapping:
		if area.has_method("can_be_picked_up") and area.can_be_picked_up():
			if area.has_method("pick_up"):
				match area.item_type:
					"gun":
						_pickup_gun(area)
					"attachment":
						_pickup_attachment(area)
					# Add more types as needed
				return
				
func _pickup_gun(gun: Node):
	if gun_inventory[0] == null:
		gun_inventory[0] = gun
		current_gun_index = 0
	elif gun_inventory[1] == null:
		gun_inventory[1] = gun
		current_gun_index = 1
	else:
		drop_gun()
		gun_inventory[current_gun_index] = gun
	equip_gun(gun)
	gun.pick_up($GunHolder)

func _pickup_attachment(attachment: Node):
	attachment.pick_up(self)
	
func drop_gun():
	var gun = get_held_gun()
	if gun:
		gun.drop(self.global_position + Vector2(0, 16), get_tree().current_scene)
		gun_inventory[current_gun_index] = null
		
func drop_guns_on_death():
	var drop_offset = Vector2(0, 16)
	if gun_inventory[0]:
		show_gun_visual(gun_inventory[0])
		gun_inventory[0].drop(global_position + drop_offset.rotated(deg_to_rad(10)), get_tree().current_scene)
		gun_inventory[0] = null
	if gun_inventory[1]:
		show_gun_visual(gun_inventory[1])
		gun_inventory[1].drop(global_position + drop_offset.rotated(deg_to_rad(-10)), get_tree().current_scene)
		gun_inventory[1] = null
	current_gun_index = 0
	
func update_pickup_button_visibility():
	var pickup_area = $PickupArea
	var overlapping = pickup_area.get_overlapping_areas()
	var found_gun = false
	for area in overlapping:
		if area.has_method("pick_up") and !area.is_picked_up:
			found_gun = true
			break
	pickup_button.visible = found_gun

func equip_gun(gun: Node):
	for g in gun_inventory:
		if g and g != gun:
			hide_gun_visual(g)
	if gun.is_connected("ammo_changed", Callable(self, "_on_ammo_changed")):
		gun.disconnect("ammo_changed", Callable(self, "_on_ammo_changed"))
	if gun.is_connected("reload_started", Callable(self, "_on_reload_started")):
		gun.disconnect("reload_started", Callable(self, "_on_reload_started"))
	gun.connect("ammo_changed", Callable(self, "_on_ammo_changed"))
	gun.connect("reload_started", Callable(self, "_on_reload_started"))
	
	hud.update_current_gun(gun)


#SIGNALS

func _on_ammo_changed(current_mag, total_ammo):
	get_node("/root/GameplayScene/Control/HUD").update_ammo(current_mag, total_ammo)

func _on_reload_started(duration: float):
	get_node("/root/GameplayScene/Control/HUD").start_reload_bar(duration)

#BUTTON PRESS FUNCTION

func _on_pickup_gun_pressed() -> void:
	if is_dead or get_held_gun() and get_held_gun().is_reloading:
		return
	pickup_item()
	
func _on_reload_gun_pressed() -> void:
	if get_held_gun():
		get_held_gun().start_reload()
		
func _on_switch_gun_pressed() -> void:
	switch_gun()

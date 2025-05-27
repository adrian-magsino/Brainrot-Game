class_name Player
extends CharacterBody2D
#extends "res://Scripts/Gameplay/Shared_Scripts/EntityHealthManager.gd"


#Root Scene
@onready var gameplay_scene = get_parent()

#Animations
@export var BloodParticle: PackedScene
@onready var animated_sprite = $AnimatedSprite2D2

##Nodes and Scenes
@export var default_gun_scene: PackedScene
@onready var camera = $Camera2D
@onready var player_name_label = $PlayerName

#HUD and Controls
@onready var control_node = get_parent().get_node("Control")
#@onready var scoreboard = control_node.get_node("Scoreboard")
@onready var hud = control_node.get_node("HUD")

@onready var touch_controls = control_node.get_node("TouchControls")
@onready var pickup_button = control_node.get_node("TouchControls/Pickup Gun")
@onready var zoom_button = control_node.get_node("TouchControls/Zoom Button")
@onready var reload_button = control_node.get_node("TouchControls/Reload Gun")
@onready var switch_gun_button = control_node.get_node("TouchControls/Switch Gun")
@onready var dash_button = control_node.get_node("TouchControls/Dash Button")
@onready var dash_progress_bar = control_node.get_node("TouchControls/Dash Button/Dash Cooldown")
@onready var sfx_blood: AudioStreamPlayer2D = $SFX_blood

@onready var health_component = get_node("HealthComponent")

#Other Properties
@onready var respawn_delay: float = 2.0
var player_name: String = "PLAYER"

var is_a_player = true
var player_score: int = 0
var player_deaths: int = 0
var is_dead: bool = false

#Camera zoom feature
var current_zoom_index: int = 0

# Attributes
@export var move_speed: int = 200

#Dash movement
@export var dash_distance: float = 150.0
@export var dash_cooldown: float = 1.5
@export var dash_duration: float = 0.1  # Duration of dash movement
var can_dash: bool = true
var dash_velocity: Vector2 = Vector2.ZERO
var dash_timer := Timer.new()

#Gun Inventory System
var gun_inventory: Array[Node] = [null, null] # Two gun slots
var current_gun_index: int = 0

var facing_left: bool = false # Sprite flipping
func _enter_tree():
	print("PLAYER NAME: " + player_name)

func _ready():
	print("CURRENT ROOT SCENE: ", gameplay_scene)
	camera.enabled = true
	pickup_button.pressed.connect(_on_pickup_gun_pressed)
	zoom_button.pressed.connect(_on_zoom_button_pressed)
	reload_button.pressed.connect(_on_reload_gun_pressed)
	switch_gun_button.pressed.connect(_on_switch_gun_pressed)
	dash_button.pressed.connect(_on_dash_button_pressed)

	player_name_label.text = player_name
	health_component.update_health_bar()
	set_default_gun()
	# Dash movement
	add_child(dash_timer)
	dash_timer.one_shot = true
	dash_timer.connect("timeout", Callable(self, "_on_dash_cooldown_timeout"))
	dash_progress_bar.visible = false
	#scoreboard.update_scoreboard(get_multiplayer_authority(), player_name, player_score, player_deaths)	
	
func _physics_process(delta):		
	var input_vector = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	#Dash movement
	var is_dashing = dash_velocity != Vector2.ZERO
	if is_dashing:
		velocity = dash_velocity
		#animated_sprite.play("Dash")
	else:
		if input_vector != Vector2.ZERO:
			input_vector = input_vector.normalized()
			velocity = input_vector * move_speed
			animated_sprite.play("Walk")
		else:
			velocity = Vector2.ZERO
			animated_sprite.play("Idle")

	move_and_slide()

	# Gun pickup/drop
	if Input.is_action_just_pressed("pickup_or_drop"):
		pickup_item()
	if Input.is_action_just_pressed("switch_gun"):
		switch_gun()
	if Input.is_action_just_pressed("zoom_in") or Input.is_action_just_pressed("zoom_out"):
		cycle_zoom()

	update_pickup_button_visibility()

	# Aiming logic
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

	#sprite.flip_h = facing_left
	animated_sprite.flip_h = facing_left

	var gun = get_held_gun()
	if gun:
		var gun_holder = gun.get_parent()
		if gun_holder and use_aiming:
			var angle = aim_direction.angle()
			var is_flipped = angle > PI / 2 or angle < -PI / 2
			gun_holder.scale.x = -1 if is_flipped else 1
			gun.rotation = PI - angle if is_flipped else angle

		if gun_holder:
			gun_holder.scale.x = -1 if facing_left else 1
		if aim_strength >= SHOOT_THRESHOLD and Input.is_action_pressed("shoot"):
			gun.shoot(aim_direction)
			
		if Input.is_action_just_pressed("reload_gun"):
			gun.start_reload()
		hud.update_ammo(gun.current_magazine, gun.total_ammo)
		
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
		
		#Add default gun in the scene before being picked up
		await get_tree().process_frame
		get_tree().current_scene.add_child(default_gun)
		default_gun.global_position = global_position
		await get_tree().process_frame

		#immediately pick up default gun after spawn/respawn
		default_gun.pick_up($GunHolder)
		gun_inventory[0] = default_gun
		current_gun_index = 0
		equip_gun(default_gun)

		update_gun_in_HUD()
		
func get_held_gun() -> Node:
	return gun_inventory[current_gun_index]

func hide_gun_visual(gun: Node):
	if gun:
		gun.visible = false
		gun.set_physics_process(false)

func show_gun_visual(gun: Node):
	if gun:
		gun.visible = true
		gun.set_physics_process(true)
		
func pickup_item():
	var pickup_area = $PickupArea
	var overlapping = pickup_area.get_overlapping_areas()
	for area in overlapping:
		if area.has_method("can_be_picked_up") and area.can_be_picked_up():
			if area.has_method("pick_up"):
				if area is Gun:
					_pickup_gun(area)
				elif area is Attachment:
					_pickup_attachment(area)
				elif area is AmmoBox:
					area.pick_up(self)
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
	gun.set_multiplayer_authority(get_multiplayer_authority())
	
	current_zoom_index = 0
	if "zoom_distance" in gun:
		if gun.zoom_distance.size() > 0:
			camera.zoom = Vector2.ONE * gun.zoom_distance[current_zoom_index]
			update_zoom_button_label(current_zoom_index + 1)
			
func add_ammo_to_current_gun():
	var gun = gun_inventory[current_gun_index]
	if gun and gun is Gun:
		gun.total_ammo += gun.max_ammo
		gun.emit_signal("ammo_changed", gun.current_magazine, gun.total_ammo)
		
func cycle_zoom():
	var gun = get_held_gun()
	if not gun or not ("zoom_distance" in gun):
		return

	var distances: Array = gun.zoom_distance
	if distances.size() == 0:
		return

	current_zoom_index += 1
	if current_zoom_index >= distances.size():
		current_zoom_index = 0

	var zoom_value = distances[current_zoom_index]
	camera.zoom = Vector2.ONE * zoom_value

	# Update HUD
	update_zoom_button_label(current_zoom_index + 1)

func dash():
	if not can_dash or is_dead:
		return

	var input_vector = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	if input_vector == Vector2.ZERO:
		return

	can_dash = false
	dash_velocity = input_vector.normalized() * (dash_distance / dash_duration)

	# Start dash cooldown visual
	dash_progress_bar.visible = true
	dash_progress_bar.max_value = dash_cooldown
	dash_progress_bar.value = 0

	var tween = create_tween()
	tween.tween_property(dash_progress_bar, "value", dash_cooldown, dash_cooldown)
	tween.connect("finished", func():
		dash_progress_bar.visible = false
	)

	dash_timer.start(dash_cooldown)
	$CollisionShape2D.disabled = true

	await get_tree().create_timer(dash_duration).timeout
	dash_velocity = Vector2.ZERO
	$CollisionShape2D.disabled = false


func increment_score(killer_id):
	player_score += 1
	#scoreboard.update_scoreboard(killer_id, player_name, player_score, player_deaths)

func increment_deaths():	
	player_deaths += 1
	#scoreboard.update_scoreboard(get_multiplayer_authority(), player_name, player_score, player_deaths)

func play_death_animation():
	var _particle = BloodParticle.instantiate()
	_particle.position = global_position
	_particle.rotation = global_rotation
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)
	sfx_blood.play()
	
func die(attack: AttackComponent):
	if is_dead:
		return
	is_dead = true
	increment_deaths()
	play_death_animation()
	drop_guns_on_death()

	hud.reset_hud()
	visible = false
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	
	await get_tree().create_timer(respawn_delay).timeout
	respawn()
	
func respawn():
	health_component.reset_health()
	
	#THESE ARE SPAWN POINTS FOR RESPAWN ONLY
	var spawn_points = get_tree().get_nodes_in_group("player_spawners")
	if spawn_points.size() > 0:
		var random_spawn = spawn_points[randi() % spawn_points.size()]
		global_position = random_spawn.global_position

	visible = true
	set_physics_process(true)
	$CollisionShape2D.disabled = false
	is_dead = false
	set_default_gun()
	
func switch_gun():
	if gun_inventory[0] != null and gun_inventory[1] != null:
		var prev_gun = get_held_gun()
		hide_gun_visual(prev_gun)
		current_gun_index = 1 - current_gun_index
		var new_gun = get_held_gun()
		show_gun_visual(new_gun)
		equip_gun(new_gun) # <- Ensures correct zoom setup
		
#SIGNALS and HUD UPDATES
func update_gun_in_HUD():
	var gun = get_held_gun()
	if gun:
		hud.update_current_gun(gun)
	
func _on_ammo_changed(current_mag, total_ammo):
	hud.update_ammo(current_mag, total_ammo)

func _on_reload_started(duration: float):
	hud.start_reload_bar(duration)

func update_pickup_button_visibility():
	var pickup_area = $PickupArea
	var overlapping = pickup_area.get_overlapping_areas()
	var found_gun = false
	for area in overlapping:
		if area.has_method("pick_up") and !area.is_picked_up:
			found_gun = true
			break
	pickup_button.visible = found_gun
	
func _on_dash_cooldown_timeout():
	can_dash = true

func update_dash_cooldown_progress(value: float):
	dash_progress_bar.value = value
	
func update_zoom_button_label(level: int):
	if zoom_button:
		zoom_button.text = "Zoom x%d" % level
		
#BUTTON PRESS FUNCTION

func _on_pickup_gun_pressed() -> void:
	if is_dead or get_held_gun() and get_held_gun().is_reloading:
		return
	pickup_item()
	update_gun_in_HUD()
	
func _on_reload_gun_pressed() -> void:
	if get_held_gun():
		get_held_gun().start_reload()
		
func _on_switch_gun_pressed() -> void:
	switch_gun()
	update_gun_in_HUD()
	
func _on_zoom_button_pressed() -> void:
	if is_dead:
		return
	cycle_zoom()
	

func _on_dash_button_pressed() -> void:
	dash()

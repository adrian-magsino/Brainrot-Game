class_name Player
extends CharacterBody2D

#Root Scene
@onready var level_scene = get_parent()

#Animations and SFX components
@onready var animated_sprite = $AnimatedSprite2D

#HUD and Controls
@onready var HUD = get_parent().get_node("HUD")
@onready var game_ui = HUD.get_node("GameUI") #Contains Player exclusive HUD elements

@onready var player_controls = HUD.get_node("PlayerControls")
@onready var pickup_button = HUD.get_node("PlayerControls/Control/Pickup Button")
@onready var zoom_button = HUD.get_node("PlayerControls//Control2/Zoom Button")
@onready var reload_button = HUD.get_node("PlayerControls/Control4/Reload Gun")
@onready var switch_gun_button = HUD.get_node("PlayerControls/Control5/Switch Gun")
@onready var dash_button = HUD.get_node("PlayerControls/Control3/Dash Button")
@onready var dash_progress_bar = HUD.get_node("PlayerControls/Control3/Dash Button/Dash Cooldown")

@onready var camera = $Camera2D
@onready var player_name_label = $PlayerName

#Notifications
@onready var notification_node = HUD.get_node("Notification")

#Components
@onready var bloody_death_animation: Node2D = $BloodyDeathAnimation
@onready var health_component = get_node("HealthComponent")
@onready var pickup_component: Area2D = $PickupArea

#Other Properties
@onready var respawn_delay: float = 2.0
var player_name: String = PLAYER_DATA.player_name

@export var player_lives = 3
var is_a_player = true
var player_score: int = 0
var player_deaths: int = 0
var is_dead: bool = false
var is_detectable: bool = true

var hit_effect_duration: float = 0.2
var hit_effect_timer: Timer

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
var is_dashing = false
var dash_time_remaining = 0.0

#Gun Inventory System
@export var default_gun_scene: PackedScene
var gun_inventory: Array[Node] = [null, null] # Two gun slots
var current_gun_index: int = 0

var facing_left: bool = false # Sprite flipping


func _ready():
	add_to_group("pauseable") #This node will pause along with the game

	camera.enabled = true
	
	#connect signals
	pickup_button.pressed.connect(_on_pickup_gun_pressed)
	zoom_button.pressed.connect(_on_zoom_button_pressed)
	reload_button.pressed.connect(_on_reload_gun_pressed)
	switch_gun_button.pressed.connect(_on_switch_gun_pressed)
	dash_button.pressed.connect(_on_dash_button_pressed)
	
	
	
	hit_effect_timer = Timer.new()
	hit_effect_timer.wait_time = hit_effect_duration
	hit_effect_timer.one_shot = true
	hit_effect_timer.connect("timeout", Callable(self, "_on_hit_effect_timeout"))
	add_child(hit_effect_timer)
	
	#initialize UI elements
	player_name_label.text = player_name
	apply_selected_skin()
	health_component.update_health_bar()
	set_default_gun()
	
	# setup dash movement components
	add_child(dash_timer)
	dash_timer.one_shot = true
	dash_timer.connect("timeout", Callable(self, "_on_dash_cooldown_timeout"))
	dash_progress_bar.visible = false
		
func _physics_process(delta):		
	# DASH HANDLING
	if is_dashing:
		var collision = move_and_collide(dash_velocity * delta)
		dash_time_remaining -= delta
		if collision or dash_time_remaining <= 0.0:
			is_dashing = false
			dash_velocity = Vector2.ZERO
	
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
			animated_sprite.play("run")
		else:
			velocity = Vector2.ZERO
			animated_sprite.play("idle")

	move_and_slide()

	# Gun pickup/drop
	if Input.is_action_just_pressed("pickup_or_drop"):
		pickup_component.pickup_item()
	if Input.is_action_just_pressed("switch_gun"):
		switch_gun()
	if Input.is_action_just_pressed("zoom_in") or Input.is_action_just_pressed("zoom_out"):
		cycle_zoom()

	pickup_component.update_pickup_button_visibility()

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
		game_ui.update_ammo(gun.current_magazine, gun.current_total_ammo)

func apply_selected_skin():
	var skin_path = get_skin_path(PLAYER_DATA.current_character)
	if skin_path != "":
		var frames = load(skin_path)
		if frames is SpriteFrames:
			animated_sprite.sprite_frames = frames

func get_skin_path(character_id: String) -> String:
	match character_id:
		"sahur": return "res://Game Assets/Character Skins/char_sahur.tres"
		"ballerina": return "res://Game Assets/Character Skins/char_ballerina.tres"
		"tralalero": return "res://Game Assets/Character Skins/char_tralalero.tres"
		"crocodilo": return "res://Game Assets/Character Skins/char_crocodilo.tres"
		"chimpanzini": return "res://Game Assets/Character Skins/char_chimpanzini.tres"
		_: return "res://Game Assets/Character Skins/char_sahur.tres" # fallback
				
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
			

		
func cycle_zoom():
	var gun = get_held_gun()
	if not gun or not ("zoom_distance" in gun):
		return
		
	ZoomSound.play()
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
	
func start_dashing():
	PlayerDashSound.play()
	is_dashing = true
	dash_time_remaining = dash_duration
	
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

	# Dash cooldown UI
	dash_progress_bar.visible = true
	dash_progress_bar.max_value = dash_cooldown
	dash_progress_bar.value = 0

	var tween = create_tween()
	tween.tween_property(dash_progress_bar, "value", dash_cooldown, dash_cooldown)
	tween.connect("finished", func():
		dash_progress_bar.visible = false
	)

	dash_timer.start(dash_cooldown)

	# Start the dash with collision enabled
	start_dashing()

func increment_score(killer_id):
	player_score += 1
	
func increment_deaths():	
	player_deaths += 1
	if player_lives > 0:
		player_lives -= 1
		update_player_lives()
	
func hit_effect() -> void:
	# Change sprite modulate to red
	animated_sprite.modulate = Color(1, 0, 0)  # bright red
	hit_effect_timer.start()

func _on_hit_effect_timeout() -> void:
	# Reset sprite color to normal
	animated_sprite.modulate = Color(1, 1, 1)  # white (default)
	
	
func die(attack: AttackComponent):
	if is_dead:
		return
	is_dead = true
	$StatusEffectManager.clear_effects()
	increment_deaths()
	bloody_death_animation.play_death_animation()
	drop_guns_on_death()

	game_ui.reset_display()
	visible = false
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	
	await get_tree().create_timer(respawn_delay).timeout
	#print("PLAYER LIVES: ", player_lives)
	if player_lives > 0:
		respawn()
	else:
		level_scene.game_defeat()
	
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

func update_player_lives():
	level_scene.player_lives_label.text = "x %d" % player_lives
	
func switch_gun():
	if gun_inventory[0] != null and gun_inventory[1] != null:
		SwitchGunSound.play()
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
		game_ui.update_current_gun(gun)
	
func _on_ammo_changed(current_mag, current_total_ammo):
	game_ui.update_ammo(current_mag, current_total_ammo)

func _on_reload_started(duration: float):
	game_ui.start_reload_bar(duration)
	
func _on_dash_cooldown_timeout():
	can_dash = true

func update_dash_cooldown_progress(value: float):
	dash_progress_bar.value = value
	
func update_zoom_button_label(level: int):
	if zoom_button:
		zoom_button.get_node("ZoomLabel").text = str(level)
		
#BUTTON PRESS FUNCTION

func _on_pickup_gun_pressed() -> void:
	if is_dead or get_held_gun() and get_held_gun().is_reloading:
		return
	pickup_component.pickup_item()
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

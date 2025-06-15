extends Area2D
class_name ExplosiveComponent

@export var explosion_damage: float = 50.0
@export var explosion_particles: PackedScene
@export var animated_sprite_path: NodePath
@export var explosion_sound_path: NodePath
@export var can_damage_attacker: bool = false


@onready var attack_component: AttackComponent = $AttackComponent


var attacker: Node = null
var is_exploded: bool = false

func _ready():
	attack_component.attack_damage = explosion_damage

func explode():
	if is_exploded:
		return
	is_exploded = true

	attack_component.attacker = attacker
	monitoring = true
	# Play explosion effects
	_play_explosion_effects()
	
	await get_tree().physics_frame
	
	# Let physics engine process overlaps
	for area in get_overlapping_areas():
		_on_area_entered(area)

	if get_parent():
		var animated_sprite: AnimatedSprite2D = get_node_or_null(animated_sprite_path)
		if animated_sprite:
			await animated_sprite.animation_finished
		get_parent().queue_free()
	# After 1 physics frame, disable monitoring
	monitoring = false

func _on_area_entered(area: Area2D) -> void:
	if not is_exploded:
		return

	if area is HitboxComponent:
		var damaged_entity = area.get_parent()
		if not can_damage_attacker and damaged_entity == attacker:
			return
		area.take_damage(attack_component)

func _play_explosion_effects():
	if explosion_particles:
		var particle_instance = explosion_particles.instantiate()
		particle_instance.global_position = global_position
		particle_instance.global_rotation = global_rotation
		particle_instance.emitting = true
		get_tree().current_scene.add_child(particle_instance)

	var animated_sprite: AnimatedSprite2D = get_node_or_null(animated_sprite_path)
	if animated_sprite:
		animated_sprite.play("explode")

	var sound: AudioStreamPlayer2D = get_node_or_null(explosion_sound_path)
	if sound:
		var detached_sfx = sound.duplicate()
		detached_sfx.global_position = global_position		
		get_tree().current_scene.add_child(detached_sfx)
		detached_sfx.play()

		# Clean it up after it finishes
		detached_sfx.finished.connect(detached_sfx.queue_free)
		
		sound.play()

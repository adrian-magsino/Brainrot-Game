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

	# Assign attacker to the attack component
	attack_component.attacker = attacker

	# Damage nearby HitboxComponents
	monitoring = true
	for area in get_overlapping_areas():
		if area is HitboxComponent:
			var damaged_entity = area.get_parent()
			if not can_damage_attacker and damaged_entity == attacker:
				continue
			area.take_damage(attack_component)
	monitoring = false

	# Play animation and effects
	_play_explosion_effects()

func _play_explosion_effects():
	if explosion_particles:
		var particle_instance = explosion_particles.instantiate()
		particle_instance.global_position = global_position
		particle_instance.global_rotation = global_rotation
		particle_instance.emitting = true
		get_tree().current_scene.add_child(particle_instance)

	var sprite: AnimatedSprite2D = get_node_or_null(animated_sprite_path)
	if sprite:
		sprite.play("explode")

	var sound: AudioStreamPlayer2D = get_node_or_null(explosion_sound_path)
	if sound:
		print("PLAY EXPLOSION SOUND")
		sound.play()

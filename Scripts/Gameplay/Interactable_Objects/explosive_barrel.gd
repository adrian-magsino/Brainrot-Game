extends StaticBody2D

#@export var explosion_damage: int = 50
@export var explosion_radius: float = 100.0
@export var ExplosionParticles: PackedScene

@onready var explosion_area = $ExplosionArea
@onready var attack_component = $AttackComponent

var is_destroyed: bool = false

func destroy(attack: AttackComponent):
	if is_destroyed:
		return
	is_destroyed = true
	#The destroyer of this explosive
	attack_component.attacker = attack.attacker 
	print("DESTROYER: ", attack_component.attacker)
	# Damage nearby bodies
	apply_explosion_damage_all(attack_component)
	play_explosion_animation()
	
	queue_free()

func apply_explosion_damage_all(attack: AttackComponent):
	if not attack:
		return
	explosion_area.monitoring = true
	for area in explosion_area.get_overlapping_areas():
		if area is HitboxComponent and area != get_node("HitboxComponent"):
			area.take_damage(attack)
	explosion_area.monitoring = false

func play_explosion_animation():
	var _particle = ExplosionParticles.instantiate()
	_particle.position = global_position
	_particle.rotation = global_rotation
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)
	

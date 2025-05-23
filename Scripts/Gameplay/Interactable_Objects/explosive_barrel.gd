extends Destructible

@onready var explosion_area = $ExplosionArea
@export var explosion_damage: int = 50
@export var explosion_radius: float = 100.0
@export var ExplosionParticles: PackedScene

func destroy(damager: Node):
	# Show explosion VFX here (optional)
	#spawn_explosion_effect()
	play_explosion_animation()
	# Damage nearby bodies
	apply_explosion_damage_all(damager)
	if is_destroyed:
		return
	is_destroyed = true
	emit_signal("destroyed")
	queue_free()

func apply_explosion_damage_all(damager: Node):
	if not damager:
		return

	print("EXPLODED")
	explosion_area.monitoring = true
	for body in explosion_area.get_overlapping_bodies():
		print("SOMETHING IN RANGE")
		if body == self:
			continue
		if body.has_method("take_damage"):
			body.take_damage(explosion_damage, damager)
			print("DAMAGED SOMETHING")
			print(damager)
	explosion_area.monitoring = false

func play_explosion_animation():
	var _particle = ExplosionParticles.instantiate()
	_particle.position = global_position
	_particle.rotation = global_rotation
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)
	

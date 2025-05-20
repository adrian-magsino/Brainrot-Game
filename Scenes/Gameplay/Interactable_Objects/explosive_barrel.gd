extends Destructible

@onready var explosion_area = $ExplosionArea
@export var explosion_damage: int = 50
@export var explosion_radius: float = 100.0

func destroy(damager: Node):
	if not is_multiplayer_authority():
		return

	# Show explosion VFX here (optional)
	#spawn_explosion_effect()

	# Damage nearby bodies
	apply_explosion_damage_all.rpc(damager.get_path())

	# Continue with base destruction logic
	sync_destroy.rpc()

@rpc("call_local")
func apply_explosion_damage_all(damager_path: NodePath):
	var damager = get_node_or_null(damager_path)
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

	
#func spawn_explosion_effect():
	#var explosion_scene = preload("res://effects/Explosion.tscn")
	#var explosion_instance = explosion_scene.instantiate()
	#get_tree().current_scene.add_child(explosion_instance)
	#explosion_instance.global_position = global_position

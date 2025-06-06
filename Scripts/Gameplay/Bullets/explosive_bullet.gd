extends Bullet
class_name ExplosiveBullet

@onready var explosive_component: ExplosiveComponent = $ExplosiveComponent
@onready var sfx_explosion: AudioStreamPlayer2D = $SFX_explosion


func _ready():
	# Make sure the explosive uses the bullet's shooter as the attacker
	explosive_component.attacker = shooter
	explosive_component.explosion_sound_path = sfx_explosion.get_path()
	

func _process(delta):
	var movement = direction * speed * delta
	position += movement
	distance_traveled += movement.length()

	if distance_traveled >= max_distance:
		explode()


func _on_body_entered(body):
	if body == shooter and not can_damage_owner:
		return

	if body is TileMapLayer:
		explode()
		

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		if area.get_parent() is Player and not can_damage_owner:
			return
		#area.take_damage(attack_component)
		explode()
		
var has_exploded := false

func explode():
	if explosive_component:
		explosive_component.attacker = shooter
		explosive_component.explode()

		# Detach and play the explosion SFX
		var detached_sfx = sfx_explosion.duplicate()
		detached_sfx.global_position = global_position		
		get_tree().current_scene.add_child(detached_sfx)
		detached_sfx.play()

		# Clean it up after it finishes
		detached_sfx.finished.connect(detached_sfx.queue_free)

extends StaticBody2D
class_name DestructibleObject

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_destroyed = false

func hit_effect():
	pass
	
func destroy(attack: AttackComponent):
	if is_destroyed:
		return
	is_destroyed = true
	
	animated_sprite_2d.play("destroy")
	
	await animated_sprite_2d.animation_finished
	queue_free()

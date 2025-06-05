extends StaticBody2D

@onready var explosive_component: ExplosiveComponent = $ExplosiveComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sfx_explosion: AudioStreamPlayer2D = $SFX_explosion

var is_destroyed: bool = false

func _ready():
	explosive_component.animated_sprite_path = animated_sprite_2d.get_path()
	explosive_component.explosion_sound_path = sfx_explosion.get_path()

func destroy(attack: AttackComponent):
	if is_destroyed:
		return
	is_destroyed = true

	explosive_component.attacker = attack.attacker
	explosive_component.explode()

	await animated_sprite_2d.animation_finished
	queue_free()

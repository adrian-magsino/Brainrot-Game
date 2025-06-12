extends Node2D

@export var BloodParticle: PackedScene
@onready var sfx_blood: AudioStreamPlayer2D = $SFX_blood

func play_death_animation():
	var _particle = BloodParticle.instantiate()
	_particle.position = global_position
	_particle.rotation = global_rotation
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)
	play_blood_sfx()
	
func play_blood_sfx():
	if sfx_blood:
		var detached_sfx = sfx_blood.duplicate()
		detached_sfx.global_position = global_position		
		get_tree().current_scene.add_child(detached_sfx)
		detached_sfx.play()

		# Clean it up after it finishes
		detached_sfx.finished.connect(detached_sfx.queue_free)
		
		sfx_blood.play()

extends CPUParticles2D

@onready var timeCreated = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if Time.get_ticks_msec() - timeCreated > 10000:
		queue_free()

extends CPUParticles2D

@onready var timeCreated = Time.get_ticks_msec()
@onready var total_duration := lifetime 
@onready var surrounding_light = get_node_or_null("SurroundingLight")

func _ready() -> void:
	if surrounding_light:
		var tween := create_tween()
		tween.tween_property(surrounding_light, "energy", 0.0, 0.5)

func _process(delta: float) -> void:
	if Time.get_ticks_msec() - timeCreated > 10000:
		queue_free()

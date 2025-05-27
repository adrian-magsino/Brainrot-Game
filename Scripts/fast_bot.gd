extends EnemyBot
class_name FastBot

@export var dash_distance: float = 50.0

func _attack_target() -> void:
	super._attack_target()
	if damageable_in_range is Player:
		position += (target_player.global_position - global_position).normalized() * dash_distance

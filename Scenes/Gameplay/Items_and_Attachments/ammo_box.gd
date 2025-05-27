extends Area2D
class_name AmmoBox

@export var pickup_amount_multiplier: float = 1.0
var is_picked_up: bool = false

func can_be_picked_up() -> bool: return true

func pick_up(player: Player):
	if not player.has_method("add_ammo_to_current_gun"):
		return
	player.add_ammo_to_current_gun()
	is_picked_up = true
	queue_free()

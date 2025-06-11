extends Area2D

@export var pickup_amount_multiplier: float = 1.0
var is_picked_up: bool = false

func can_be_picked_up() -> bool: return true

func pick_up(player: Player):
	if not player or is_picked_up: #has_method("add_ammo_to_current_gun"):
		return

	is_picked_up = true
	var parent = get_parent()
	if parent and parent.has_method("on_picked_up"):
		parent.on_picked_up(player)
	parent.queue_free()

extends Node2D
class_name AmmoBox

@onready var pickupable_area: Area2D = $PickupableArea

func on_picked_up(player: Player):
	add_ammo_to_current_gun(player)
	
func add_ammo_to_current_gun(player: Player):
	var gun = player.gun_inventory[player.current_gun_index]
	if gun and gun is Gun:
		if gun.max_ammo == 0: #for special types of gun 
			gun.current_total_ammo += 100
		else:
			gun.current_total_ammo += gun.max_ammo
		gun.emit_signal("ammo_changed", gun.current_magazine, gun.current_total_ammo)

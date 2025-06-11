extends Area2D

@onready var player: Player = $".."

func pickup_item():
	#var pickup_area = $PickupArea
	var overlapping = get_overlapping_areas()
	for area in overlapping:
		if area.has_method("can_be_picked_up") and area.can_be_picked_up():
			if area.has_method("pick_up"):
				if area is Gun:
					_pickup_gun(area)
				#elif area is Attachment:
					#_pickup_attachment(area)
				elif area is AmmoBox:
					area.pick_up(player)
			return
				
func _pickup_gun(gun: Node):
	if player.gun_inventory[0] == null:
		player.gun_inventory[0] = gun
		player.current_gun_index = 0
	elif player.gun_inventory[1] == null:
		player.gun_inventory[1] = gun
		player.current_gun_index = 1
	else:
		player.drop_gun()
		player.gun_inventory[player.current_gun_index] = gun
	player.equip_gun(gun)
	gun.pick_up($"../GunHolder")
	
func update_pickup_button_visibility():
	#var pickup_area = $PickupArea
	var overlapping = get_overlapping_areas()
	var found_gun = false
	for area in overlapping:
		if area.has_method("pick_up") and !area.is_picked_up:
			found_gun = true
			break
	player.pickup_button.visible = found_gun

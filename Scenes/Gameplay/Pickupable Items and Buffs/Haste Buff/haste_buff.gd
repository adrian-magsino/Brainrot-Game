extends Node2D
class_name HasteBuff

@export var item_name = "Haste Buff"
var buff_duration: float = 10

func on_picked_up(player: Player):
	apply_haste_buff(player)
	
func apply_haste_buff(player: Player):
	if player and player.has_node("StatusEffectManager"):
		var status_effect_manager = player.get_node("StatusEffectManager")
		status_effect_manager.apply_status_effect(status_haste.new(buff_duration))

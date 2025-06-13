extends Node2D
class_name InvisibilityBuff

@export var item_name = "Invisibility Buff"
var buff_duration: float = 10

func on_picked_up(player: Player):
	apply_invisibility_buff(player)
	
func apply_invisibility_buff(player: Player):
	if player and player.has_node("StatusEffectManager"):
		var status_effect_manager = player.get_node("StatusEffectManager")
		status_effect_manager.apply_status_effect(status_invisible.new(buff_duration))

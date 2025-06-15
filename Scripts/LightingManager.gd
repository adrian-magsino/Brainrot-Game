extends Node

var lights_enabled := false

func set_lighting_enabled(enabled: bool) -> void:
	lights_enabled = enabled
	for light in get_tree().get_nodes_in_group("lighting"):
		light.visible = enabled

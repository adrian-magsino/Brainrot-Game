extends Resource
class_name StatusEffect

var duration: float
@export var status_name: String

func _init(time = 3):
	duration = time

func get_status_name():
	return status_name
	
func apply(target):
	if target is Player:
		var status_display = target.HUD.get_node("PlayerStatusContainer")
		status_display.find_child(status_name).show()
	print(status_name + " inflicted on " + target.name)

func remove(target):
	if target is Player:
		var status_display = target.HUD.get_node("PlayerStatusContainer")
		status_display.find_child(status_name).hide()
	print(status_name + " effect removed from " + target.name)

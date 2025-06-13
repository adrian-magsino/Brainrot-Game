extends StatusEffect
class_name status_haste

func _init(time=3):
	super._init(time)
	status_name = "Haste"
	
func apply(target):
	super.apply(target)
	target.move_speed = target.move_speed * 2
	print("move speed: ", target.move_speed)
	
func remove(target):
	super.remove(target)
	target.move_speed = target.move_speed / 2
	print("move speed: ", target.move_speed)
	

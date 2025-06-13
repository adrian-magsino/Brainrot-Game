extends StatusEffect
class_name status_invisible

func _init(time=3):
	super._init(time)
	status_name = "Invisible"
	
func apply(target):
	super.apply(target)
	target.is_detectable = false
	target.get_node("AnimatedSprite2D").visible = false
	
func remove(target):
	super.remove(target)
	target.is_detectable = true
	target.get_node("AnimatedSprite2D").visible = true

extends Node2D

var status_effects: Array = []
@onready var target = get_parent()

func _ready() -> void:
	add_to_group("pauseable")
	
func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_1:
			apply_status_effect(status_haste.new(5))
			
func _process(delta: float) -> void:
	for i in range(status_effects.size()):
		var effect = status_effects[i]
		effect.duration -= delta
		
		if effect.duration < 0:
			effect.remove(target)
			status_effects.remove_at(i)
			print("STATUS EFFECTS: ", status_effects)
			reset_effect
			break

func apply_status_effect(effect):
	for i in range(status_effects.size()):
		if status_effects[i].get_status_name() == effect.get_status_name():
			status_effects[i].duration = effect.duration
			print("REAPPLIED STATUS EFFECT: ", status_effects)
			return
	status_effects.append(effect)
	effect.apply(target)
	print("STATUS EFFECTS: ", status_effects)

func reset_effect():
	for i in status_effects:
		i.apply(target)
		
func clear_effects():
	for i in range(status_effects.size()):
		var effect = status_effects[i]
		effect.remove(target)
		status_effects.remove_at(i)
	print("CLEARED EFFECTS")
	

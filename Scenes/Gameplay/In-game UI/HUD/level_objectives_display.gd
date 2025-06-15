extends CenterContainer

@onready var objectives_label: Label = $Objectives

func _ready() -> void:
	show_objectives()
	
func show_objectives():
	objectives_label.modulate.a = 1.0
	objectives_label.visible = true
	
	await get_tree().create_timer(3.0).timeout
	
	var tween = create_tween()
	
	tween.tween_property(objectives_label, 
	"modulate:a", 
	0.0, 1.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	
	await tween.finished
	objectives_label.visible = false
	
func _on_level_objectives_button_pressed() -> void:
	ButtonClick.play_button_click()
	show_objectives()

extends Control

@export var debug_mode: bool = false
@export var pickup_label_node: PackedScene = preload("res://Scenes/Gameplay/In-game UI/Popup Notification/pickedup_item_label.tscn")

@onready var pickup_notif_container: VBoxContainer = $PickupNotification/PickupNotifContainer

func _input(event):
	if event is InputEventKey and debug_mode:
		if event.pressed and event.keycode == KEY_1:
			show_pickup_notif()

func show_pickup_notif(message = "Item"):
	var notif_label: Label = pickup_label_node.instantiate()
	notif_label.text = message
	pickup_notif_container.add_child(notif_label)
	
	var tween: Tween = notif_label.create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(notif_label.queue_free)

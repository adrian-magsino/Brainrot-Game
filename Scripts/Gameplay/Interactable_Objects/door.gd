extends Node2D

@onready var interactable: Area2D = $Interactable
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $Door2/StaticBody2D/CollisionShape2D

func _ready() -> void:
	interactable.interact = _on_interact

var is_open = false

func _on_interact():
	if interactable.is_interactable:
		if is_open:
			animation.play_backwards("door_animation")	
			is_open = false
			collision_shape_2d.disabled = false
		else:
			animation.play("door_animation")
			is_open = true
			collision_shape_2d.disabled = true

extends Area2D

#PICKUP/DROP MECHANICS
@export var gun_name: String = "SampleGun"
var is_picked_up: bool = false

#SHOOTING



func _ready():
	pass
	
func pick_up(parent_node: Node2D):
	is_picked_up = true
	get_node("CollisionShape2D").disabled = true
	self.get_parent().remove_child(self)
	parent_node.add_child(self)
	self.position = Vector2.ZERO  # reset relative position

func drop(position: Vector2, parent_node: Node):
	is_picked_up = false
	self.get_parent().remove_child(self)
	parent_node.add_child(self)
	self.global_position = position
	get_node("CollisionShape2D").disabled = false
	

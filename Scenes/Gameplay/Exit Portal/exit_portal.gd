extends Node2D
@onready var interactable: Area2D = $Interactable
@export var delay_before_victory: float = 1.0 # seconds
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var player_inside := false

func _ready():
	interactable.interact = _on_interact
	
func _on_interact():
	if interactable.is_interactable:
		#print("Victory")
		var level_node = get_tree().current_scene
		if level_node.has_method("game_victory"):
			level_node.game_victory()
		
func _on_interactable_body_entered(body: Node2D) -> void:
	if body is Player and not player_inside:
		player_inside = true
		animated_sprite_2d.play("open_portal")
		await get_tree().create_timer(delay_before_victory).timeout
		interactable.is_interactable = true
		
func _on_interactable_body_exited(body: Node2D) -> void:
	if body is Player:
		player_inside = false
		animated_sprite_2d.play("close_portal")
		interactable.is_interactable = false

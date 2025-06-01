extends Area2D

@export var target_group: String = "player" # Or use a specific NodePath if only one player

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	if body.is_in_group(target_group):
		print("Victory")
		var level_node = get_tree().current_scene
		if level_node.has_method("show_victory_screen"):
			level_node.show_victory_screen()

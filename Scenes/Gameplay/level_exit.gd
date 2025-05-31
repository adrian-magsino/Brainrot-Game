extends Area2D

@export var target_group: String = "player" # Or use a specific NodePath if only one player

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	if body.is_in_group(target_group):
		print("Victory")
		get_tree().paused = true

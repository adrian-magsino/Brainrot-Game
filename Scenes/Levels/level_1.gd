extends Level_Manager

const level: String = "lvl1"

@export var required_kills: int = 5
@onready var exit_portal: Node2D = $ExitPortal
@onready var portal_interactable_component: Area2D = exit_portal.get_node("Interactable")
const win_condition = "Kill %d enemies to open the portal"

func _ready() -> void:
	exit_portal.visible = false
	portal_interactable_component.set_deferred("monitorable", false)
	portal_interactable_component.set_deferred("monitoring", false)
	
func check_win_condition():
	if enemies_killed >= required_kills:
		exit_portal.visible = true
		portal_interactable_component.set_deferred("monitorable", true)
		portal_interactable_component.set_deferred("monitoring", true)
	
func register_enemy_kill(attacker: Node) -> void:
	super.register_enemy_kill(attacker)
	check_win_condition()

func game_victory():
	super.game_victory()
	save_level_progress()
	
func save_level_progress():
	if level_cleared:
		print(level + " CLEARED!")
		GAME_PROGRESS.level_completed[level] = true
		GAME_PROGRESS.save_progress()

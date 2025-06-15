extends Level_Manager



@export var required_kills: int = 5
@onready var exit_portal: Node2D = $ExitPortal
@onready var portal_interactable_component: Area2D = exit_portal.get_node("Interactable")
var portal_unlocked: bool = false
var updated_objectives_text = "PORTAL IS NOW OPEN!\nFIND THE PORTAL"

func _ready() -> void:
	Bgm.stop()
	PLAYER.update_player_lives()
	level_objectives = "KILL %d ENEMIES\nTO UNLOCK THE PORTAL" % required_kills
	update_objectives_display(level_objectives)
	exit_portal.visible = false
	portal_interactable_component.set_deferred("monitorable", false)
	portal_interactable_component.set_deferred("monitoring", false)
	if require_lighting:
		LightingManager.set_lighting_enabled(true)
	else:
		LightingManager.set_lighting_enabled(false)
	play_level_bgm()
	
func check_win_condition():
	if enemies_killed >= required_kills:
		portal_unlocked = true
		exit_portal.visible = true
		portal_interactable_component.set_deferred("monitorable", true)
		portal_interactable_component.set_deferred("monitoring", true)
		update_objectives_display(updated_objectives_text)
	
func register_enemy_kill(attacker: Node) -> void:
	super.register_enemy_kill(attacker)
	if not portal_unlocked:
		check_win_condition()

func game_victory():
	super.game_victory()
	save_level_progress()
	
func save_level_progress():
	if level_cleared:
		var level_name = get_name()
		#print(level_name + " CLEARED!")
		GAME_PROGRESS.level_completed[level_name] = true
		GAME_PROGRESS.save_progress()

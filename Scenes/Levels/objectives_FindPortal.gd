extends Level_Manager

@export var level_id: int
@export var require_lighting: bool

func _ready() -> void:
	Bgm.stop()
	PLAYER.update_player_lives()
	level_objectives = "FIND THE PORTAL"
	update_objectives_display(level_objectives)
	if require_lighting:
		LightingManager.set_lighting_enabled(true)
	else:
		LightingManager.set_lighting_enabled(false)

func game_victory():
	super.game_victory()
	save_level_progress()
	
func save_level_progress():
	if level_cleared:
		var level_name = get_name()
		print(level_name + " CLEARED!")
		GAME_PROGRESS.level_completed[level_name] = true
		GAME_PROGRESS.save_progress()

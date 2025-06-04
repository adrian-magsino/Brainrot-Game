extends Level_Manager

const level: String = "lvl2"

func game_victory():
	super.game_victory()
	save_level_progress()
	
func save_level_progress():
	if level_cleared:
		print(level + " CLEARED!")
		GAME_PROGRESS.level_completed[level] = true
		GAME_PROGRESS.save_progress()

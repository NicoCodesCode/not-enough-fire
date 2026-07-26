extends Node


enum Location { FOREST, CAMP, HOW_TO_PLAY, MAIN_MENU }


@warning_ignore("unused_signal")
signal location_change_requested(destination: Location)

@warning_ignore("unused_signal")
signal reached_final_level


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

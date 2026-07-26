extends Node


var branches_collected := 0
var current_coldness := 0.0
var current_level := 0
var is_first_time_forest := true
var is_first_time_camp := true
var current_location := SignalBus.Location.MAIN_MENU


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

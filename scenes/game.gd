extends Node


@export var pause_overlay: CanvasLayer

const MAIN_MENU_SCENE := preload("res://scenes/menu/main_menu.tscn")
const HOW_TO_PLAY_SCENE := preload("res://scenes/menu/how_to_play.tscn")
const FOREST_SCENE := preload("res://scenes/forest/forest.tscn")
const CAMP_SCENE := preload("res://scenes/camp/camp.tscn")
const ENDING_SCENE := preload("res://scenes/ending.tscn")


func _ready() -> void:
	SignalBus.location_change_requested.connect(_on_location_change_requested)
	SignalBus.reached_final_level.connect(_on_reached_final_level)
	
	_change_location(MAIN_MENU_SCENE)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		var current_mode = DisplayServer.window_get_mode()
		if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif event.is_action_pressed("pause"):
		if get_tree().paused:
			get_tree().paused = false
			pause_overlay.visible = false
		elif GameData.current_location != SignalBus.Location.MAIN_MENU and GameData.current_location != SignalBus.Location.HOW_TO_PLAY:
			get_tree().paused = true
			pause_overlay.visible = true


func _change_location(target_scene: PackedScene) -> void:
	for child in get_children():
		if child == pause_overlay:
			continue
		child.queue_free()
	
	var new_scene_instance = target_scene.instantiate()
	add_child(new_scene_instance)


func _on_location_change_requested(destination: SignalBus.Location):
	if destination == SignalBus.Location.CAMP:
		GameData.current_location = SignalBus.Location.CAMP
		_change_location(CAMP_SCENE)
	elif destination == SignalBus.Location.FOREST:
		GameData.current_location = SignalBus.Location.FOREST
		_change_location(FOREST_SCENE)
	elif destination == SignalBus.Location.HOW_TO_PLAY:
		GameData.current_location = SignalBus.Location.HOW_TO_PLAY
		_change_location(HOW_TO_PLAY_SCENE)


func _on_reached_final_level():
	_change_location(ENDING_SCENE)

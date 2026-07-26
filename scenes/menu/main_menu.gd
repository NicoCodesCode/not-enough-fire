extends Node2D


@export var start_button: Button
@export var quit_button: Button
@export var blue_screen: CanvasLayer
@export var fire_crackling_sfx: AudioStreamPlayer
@export var music: AudioStreamPlayer


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_start_pressed() -> void:
	blue_screen.visible = true
	fire_crackling_sfx.stop()
	music.stop()
	await get_tree().create_timer(1.0).timeout
	SignalBus.location_change_requested.emit(SignalBus.Location.HOW_TO_PLAY)

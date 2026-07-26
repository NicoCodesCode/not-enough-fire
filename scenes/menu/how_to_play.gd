extends Node2D


@export var title: CanvasLayer
@export var forest_background_color: CanvasLayer
@export var forest_instructions: CanvasLayer
@export var camp_background_color: CanvasLayer
@export var camp_instructions: CanvasLayer
@export var skip_button: Button
@export var next_button: Button
@export var start_button: Button
@export var ambient: AudioStreamPlayer


func _start_game() -> void:
	ambient.stop()
	
	title.visible = false
	
	forest_background_color.visible = true
	forest_instructions.visible = false
	camp_background_color.visible = false
	camp_instructions.visible = false
	
	next_button.visible = false
	next_button.disabled = true
	start_button.visible = false
	start_button.disabled = true
	skip_button.visible = false
	skip_button.disabled = true
	
	await get_tree().create_timer(1.0).timeout
	
	SignalBus.location_change_requested.emit(SignalBus.Location.FOREST)


func _on_next_pressed() -> void:
	forest_background_color.visible = false
	forest_instructions.visible = false
	camp_background_color.visible = true
	camp_instructions.visible = true
	
	next_button.visible = false
	next_button.disabled = true
	start_button.visible = true
	start_button.disabled = false


func _on_start_pressed() -> void:
	_start_game()


func _on_skip_pressed() -> void:
	_start_game()

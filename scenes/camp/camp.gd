extends Node2D

@export var background: Node2D
@export var textbox: CanvasLayer
@export var item_counter: CanvasLayer
@export var cold_meter: CanvasLayer
@export var hint: CanvasLayer
@export var flames_sfx: AudioStreamPlayer
@export var cool_down_sfx: AudioStreamPlayer

const LEVEL_COLORS = {
	"level_0": Color(1.0, 0.471, 0.275),
	"level_1": Color(2.454, 1.195, 0.729),
	"level_2": Color(4.416, 2.172, 1.341),
	"level_3": Color(7.911, 3.914, 2.433),
	"level_4": Color(14.139, 7.016, 4.378)
}

var _upgrade_cost := 5


func _ready() -> void:
	_set_background_color()
	cold_meter.is_active = false
	
	if GameData.is_first_time_camp:
		hint.visible = true
		GameData.is_first_time_camp = false


func _set_background_color() -> void:
	background.modulate = LEVEL_COLORS["level_" + str(GameData.current_level)]


func _input(event: InputEvent) -> void:
	if textbox.visible or GameData.current_level == 4:
		return
	
	if event.is_action_pressed("change_location"):
		textbox.update_prompt(textbox.prompts.enter_forest)
		textbox.show_prompt()
	elif event.is_action_pressed("interact") and not textbox.options_container.visible:
		textbox.update_prompt(textbox.prompts.upgrade_campfire)
		textbox.show_prompt()
	elif event.is_action_pressed("cool_yourself_down") and GameData.current_coldness > 0.0:
		hint.visible = false
		
		cold_meter.add_coldness(-5.0)
		cold_meter.update_progress_bar()
		cool_down_sfx.play()


func _on_textbox_selected_upgrade_campfire() -> void:
	if GameData.branches_collected < _upgrade_cost:
		textbox.start_dialogue("It demands a sacrifice of " + str(_upgrade_cost) + " branches to upgrade")
		return
	
	flames_sfx.play()
	
	GameData.branches_collected -= _upgrade_cost
	GameData.current_level += 1
	item_counter.set_counter_label()
	
	if GameData.current_level < LEVEL_COLORS.size():
		_set_background_color()
	
	if GameData.current_level == 4:
		textbox.hide_textbox()
		await get_tree().create_timer(2.0).timeout
		SignalBus.reached_final_level.emit()
	else:
		textbox.start_dialogue("It's burning brighter... but not enough")

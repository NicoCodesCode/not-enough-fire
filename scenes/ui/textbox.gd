extends CanvasLayer

signal hidden
signal selected_pick_up_wood(object: String)
signal selected_pick_up_lighter
signal selected_upgrade_campfire

const TYPING_SPEED := 0.02

@export var dialogue: Label
@export var options_container: HBoxContainer
@export var yes_button: Button
@export var no_button: Button
@export var dialogue_sfx: AudioStreamPlayer

var _animation_ended := false

var prompts = {
	pick_up_branch = "Steal it?",
	pick_up_lighter = "Disturb its rest and flick it?",
	pick_up_chair = "Harvest its legs?",
	go_to_camp = "Drag yourself back to camp?",
	enter_forest = "Trespass the forest?",
	upgrade_campfire = "Enrich this pathetic ember?"
}
var current_prompt := ""


func start_dialogue(dialogue_text: String) -> void:
	visible = true
	options_container.visible = false
	dialogue.text = dialogue_text
	_play_typewriter_animation()


func hide_textbox() -> void:
	visible = false
	options_container.visible = false
	hidden.emit()


func show_prompt() -> void:
	dialogue.text = current_prompt
	
	visible = true
	yes_button.disabled = false
	no_button.disabled = true
	options_container.visible = true
	
	_play_typewriter_animation()


func _play_typewriter_animation() -> void:
	dialogue.visible_characters = 0
	_animation_ended = false
	dialogue_sfx.play()

	var tween: Tween = create_tween()
	tween.tween_property(dialogue, "visible_characters", dialogue.text.length(), dialogue.text.length() * TYPING_SPEED).from(0)
	await tween.finished
	_animation_ended = true
	dialogue_sfx.stop()


func _input(event: InputEvent) -> void:
	if not visible or not _animation_ended:
		return

	if options_container.visible:
		if event.is_action_pressed("move_right"):
			yes_button.disabled = true
			no_button.disabled = false
		elif event.is_action_pressed("move_left"):
			yes_button.disabled = false
			no_button.disabled = true
		elif event.is_action_pressed("interact"):
			_handle_option_selected(not yes_button.disabled)
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") and current_prompt:
		show_prompt()
		get_viewport().set_input_as_handled()


func update_prompt(new_prompt: String) -> void:
	current_prompt = new_prompt


func _handle_option_selected(selected_yes: bool) -> void:
	if not selected_yes:
		hide_textbox()
		return
	
	match dialogue.text:
		prompts.pick_up_branch:
			selected_pick_up_wood.emit("branch")
		prompts.pick_up_chair:
			selected_pick_up_wood.emit("chair")
		prompts.pick_up_lighter:
			selected_pick_up_lighter.emit()
		prompts.go_to_camp:
			SignalBus.location_change_requested.emit(SignalBus.Location.CAMP)
		prompts.enter_forest:
			SignalBus.location_change_requested.emit(SignalBus.Location.FOREST)
		prompts.upgrade_campfire:
			selected_upgrade_campfire.emit()

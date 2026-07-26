extends Node2D


@warning_ignore("unused_signal")
signal event_triggered

@export var adriana: CharacterBody2D
@export var textbox: CanvasLayer
@export var item_counter: CanvasLayer
@export var cold_meter: CanvasLayer
@export var hint: CanvasLayer
@export var picked_up_branch_sfx: AudioStreamPlayer
@export var picked_up_lighter_sfx: AudioStreamPlayer
@export var branch_break_sfx: AudioStreamPlayer
@export var bush_rustling_sfx: AudioStreamPlayer
@export var fox_cue_player: FoxCuePlayer

var steps_until_next_event : int = 0
var _events := {
	"step_on_branch": 50,
	"find_lighter": 30,
	"find_chair": 20,
}

var _current_cue_direction := FoxCuePlayer.CueDirection.NONE
var _is_cue_pending := false
var _is_listening_for_fox_response := false
var _is_running_away = false


func _ready() -> void:
	randomize()
	_generate_next_event_distance()
	fox_cue_player.schedule_fox_cue()


func _input(event: InputEvent) -> void:
	if _is_running_away or textbox.visible:
		return
	
	if event.is_action_pressed("change_location"):
		adriana.stop_player()
		textbox.update_prompt(textbox.prompts.go_to_camp)
		textbox.show_prompt()


func _get_random_event() -> String:
	var total_weight := 0
	for weight in _events.values():
		total_weight += weight
	
	var roll := randi_range(0, total_weight -1)
	
	for event_name in _events:
		var weight = _events[event_name]
		if roll < weight:
			return event_name
		roll -= weight
	
	return ""


func _generate_next_event_distance() -> void:
	steps_until_next_event = randi_range(50, 100)


func _continue_walking() -> void:
	_generate_next_event_distance()
	adriana.set_physics_process(true)
	fox_cue_player.schedule_fox_cue()


func _evaluate_player_response_on_fox() -> void:
	if not _is_listening_for_fox_response:
		return
	
	_is_listening_for_fox_response = false
	var move_direction := Input.get_axis("move_left", "move_right")
	var moved_towards_fox := (_current_cue_direction == FoxCuePlayer.CueDirection.LEFT and move_direction < 0) or \
		(_current_cue_direction == FoxCuePlayer.CueDirection.RIGHT and move_direction > 0)
	
	if moved_towards_fox:
		_runaway()
	elif not _is_cue_pending:
		_is_cue_pending = true
		fox_cue_player.schedule_fox_cue()


func _runaway() -> void:
	_is_running_away = true
	textbox.current_prompt = ""
	
	adriana.stop_player()
	bush_rustling_sfx.play()
	
	textbox.start_dialogue("You caught something watching you from the dark and fled in panic")
	await get_tree().create_timer(3.0).timeout
	textbox.hide_textbox()
	
	GameData.branches_collected = 0
	cold_meter.add_coldness(100.0)
	SignalBus.location_change_requested.emit(SignalBus.Location.CAMP)


func _on_event_triggered() -> void:
	_is_listening_for_fox_response = false
	_is_cue_pending = false
	fox_cue_player.cue_timer.stop()
	
	branch_break_sfx.play()
	await get_tree().create_timer(1.0).timeout
	
	var selected_event = _get_random_event()
	
	match selected_event:
		"step_on_branch":
			textbox.update_prompt(textbox.prompts.pick_up_branch)
			textbox.start_dialogue("You crushed a small branch with your foot")
		"find_lighter":
			textbox.update_prompt(textbox.prompts.pick_up_lighter)
			textbox.start_dialogue("You spotted an old lighter")
		"find_chair":
			textbox.update_prompt(textbox.prompts.pick_up_chair)
			textbox.start_dialogue("You found a wooden chair that has given up on life")


func _on_textbox_hidden() -> void:
	_continue_walking()


func _on_textbox_selected_pick_up_wood(object: String) -> void:
	if adriana.too_cold:
		textbox.options_container.visible = false
		textbox.start_dialogue("Your frozen hands refused to cooperate with your ambitions")
		return
	
	textbox.hide_textbox()
	
	if object == "branch":
		GameData.branches_collected += 1
	elif object == "chair":
		GameData.branches_collected += 3
	
	item_counter.set_counter_label()
	picked_up_branch_sfx.play()


func _on_cold_meter_over_75() -> void:
	adriana.too_cold = true
	
	if GameData.is_first_time_forest:
		hint.visible = true
		GameData.is_first_time_forest = false


func _on_textbox_selected_pick_up_lighter() -> void:
	textbox.hide_textbox()
	cold_meter.add_coldness(-30.0)
	cold_meter.is_active = true
	picked_up_lighter_sfx.play()


func _on_cold_meter_under_75() -> void:
	adriana.too_cold = false


func _on_fox_cue_player_cue_played(direction: FoxCuePlayer.CueDirection) -> void:
	_is_cue_pending = false
	_current_cue_direction = direction
	_is_listening_for_fox_response = true
	
	await get_tree().create_timer(0.6).timeout
	_evaluate_player_response_on_fox()

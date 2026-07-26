extends Node2D


signal fade_finished


@export var textbox: CanvasLayer
@export var color_rect: ColorRect


const ENDING_DIALOGUE := [
	"The flames swallowed your body whole",
	"For a second, you felt warm",
	"But not enough",
	"It wasn't the right kind of heat",
	"Now, you'll never feel it again",
	"Forget it",
	"Let's just go home",
]


func _ready() -> void:
	_run_ending_dialogue()


func _run_ending_dialogue() -> void:
	await get_tree().create_timer(1.5).timeout
	
	for dialogue in ENDING_DIALOGUE:
		textbox.start_dialogue(dialogue)
		await get_tree().create_timer(3.0).timeout
	
	_end_game()


func _end_game() -> void:
	textbox.hide_textbox()
	_fade_out()


func _fade_out(duration: float = 3.0) -> void:
	var tween := create_tween()
	tween.tween_property(color_rect, "color", Color(0, 0, 0, 1.0), duration)
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	fade_finished.emit()


func _on_fade_finished() -> void:
	get_tree().quit()

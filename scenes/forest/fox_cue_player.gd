class_name FoxCuePlayer
extends AudioStreamPlayer

signal cue_played(direction: CueDirection)

enum CueDirection { NONE, LEFT, RIGHT }

var _fox_cues: Array[AudioStream] = [
	preload("res://assets/sfx/fox.mp3"),
	preload("res://assets/sfx/fox2.mp3"),
	preload("res://assets/sfx/fox3.mp3")
]

@onready var cue_timer := Timer.new()


func _ready() -> void:
	add_child(cue_timer)
	cue_timer.one_shot = true
	cue_timer.timeout.connect(_play_cue)


func schedule_fox_cue() -> void:
	cue_timer.start(4.0)


func _play_cue() -> void:
	var direction := CueDirection.NONE
	
	if randi() % 2 == 0:
		bus = "Fox_Left"
		direction = CueDirection.LEFT
	else:
		bus = "Fox_Right"
		direction = CueDirection.RIGHT
	
	stream = _fox_cues.pick_random()
	play()
	
	cue_played.emit(direction)

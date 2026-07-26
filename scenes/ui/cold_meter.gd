extends CanvasLayer


signal over_75
signal under_75

@export var progress_bar: TextureProgressBar

const MAX_VALUE := 100.0
const DURATION := 60.0

var _fill_rate := MAX_VALUE / DURATION
var _signal_emitted := false
var is_active := true


func _ready() -> void:
	progress_bar.value = GameData.current_coldness
	is_active = true


func _process(delta: float) -> void:
	if not is_active:
		return
	
	GameData.current_coldness += _fill_rate * delta
	GameData.current_coldness = clamp(GameData.current_coldness, 0.0, MAX_VALUE)
	
	if GameData.current_coldness == MAX_VALUE:
		is_active = false
	elif GameData.current_coldness >= 75.0 and not _signal_emitted:
		_signal_emitted = true
		over_75.emit()
	elif GameData.current_coldness < 75.0:
		_signal_emitted = false
		under_75.emit()
	
	update_progress_bar()


func add_coldness(amount: float) -> void:
	GameData.current_coldness = clamp(GameData.current_coldness + amount, 0.0, MAX_VALUE)


func update_progress_bar() -> void:
	progress_bar.value = GameData.current_coldness

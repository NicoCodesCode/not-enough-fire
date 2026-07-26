extends Camera2D

@export var noise: FastNoiseLite
const MOVEMENT_SPEED := 1.0
const MAX_OFFSET := Vector2(40, 32)
const MAX_ROLL := 0.02

var time := 0.0

func _ready() -> void:
	if not noise:
		noise = FastNoiseLite.new()
		noise.frequency = 0.05
	randomize()
	noise.seed = randi()

func _process(delta: float) -> void:
	time += delta * MOVEMENT_SPEED
	
	var drift_x = noise.get_noise_1d(time) * MAX_OFFSET.x
	var drift_y = noise.get_noise_2d(time, 1000.0) * MAX_OFFSET.y
	var drift_r = noise.get_noise_2d(time, 2000.0) * MAX_ROLL
	
	offset = Vector2(drift_x, drift_y)
	rotation = drift_r

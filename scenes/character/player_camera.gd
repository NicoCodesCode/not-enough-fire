extends Camera2D

@export var player: CharacterBody2D
var follow_speed: float = 10.0

var max_tilt_degrees: float = 1.5
var tilt_speed: float = 1.0
const PLAYER_SPEED: float = 500.0


func _process(delta: float) -> void:
	global_position = global_position.lerp(player.global_position, follow_speed * delta)

	var speed_ratio: float = clamp(player.velocity.x / PLAYER_SPEED, -1.0, 1.0)
	var target_radians: float = deg_to_rad(speed_ratio * max_tilt_degrees)
	
	rotation = lerp_angle(rotation, target_radians, tilt_speed * delta)

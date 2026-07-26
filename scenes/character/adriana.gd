extends CharacterBody2D


const SPEED := 500.0
const STEP_SIZE := 100


@export var animated_sprite: AnimatedSprite2D
@export var footsteps_sfx: AudioStreamPlayer

const FOOTSTEPS_DELAY := 0.4
var footsteps_timer := 0.0

var distance_walked := 0.0
var current_steps := 0

var too_cold := false


func _physics_process(delta: float) -> void:
	var initial_position := position
	
	_handle_input()
	move_and_slide()
	
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x < 0
		animated_sprite.play("walk")
		footsteps_timer -= delta
		
		if footsteps_timer <= 0.0:
			footsteps_sfx.play()
			footsteps_timer = FOOTSTEPS_DELAY
	else:
		animated_sprite.play("idle")
		footsteps_timer = 0.0
	
	distance_walked += position.distance_to(initial_position)
	current_steps = int(distance_walked / STEP_SIZE)
	
	if current_steps >= get_parent().steps_until_next_event:
		stop_player()
		reset_steps()
		get_parent().event_triggered.emit()


func stop_player() -> void:
	velocity = Vector2.ZERO
	animated_sprite.play("idle")
	footsteps_sfx.stop()
	set_physics_process(false)


func reset_steps() -> void:
	distance_walked = 0.0
	current_steps = 0


func _handle_input() -> void:
	var input_direction := Input.get_axis("move_left", "move_right")
	velocity.x = input_direction * SPEED 

extends KinematicBody2D


export var gravity_strength := 0.2
export var max_fall_speed := 300.0

export var walk_force := 100.0

export var jump_strength := 200.0

export var jet_pack_fuel_duration := 1.5
export var jet_pack_thrust_strength := 100.0

var velocity := Vector2.ZERO

enum State {IDLE, RUN, FALL, JUMP, JET_PACK, ON_WALL}
var player_state = State.IDLE

onready var debug_label := $debug_label


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	# get input
	var walk_input = Input.get_axis("move_left", "move_right")
	var is_jumping = Input.is_action_pressed("move_jump")
	
	print(walk_input)
	
	# determine state (may have to be done in the state code below)
	
	
	# move player based on state
	# TODO: consider adding floor detect distance
	match player_state:
		State.IDLE:
			debug_label.text = "IDLE"
			if ( not is_zero_approx(walk_input) ):# and is_on_floor():
				player_state = State.RUN
		
		State.RUN:
			debug_label.text = "RUN"
			if ( is_zero_approx(walk_input) ):# and is_on_floor():
				player_state = State.IDLE
		
		State.FALL:
			debug_label.text = "FALL"
		
		State.JUMP:
			debug_label.text = "JUMP"
		
		State.JET_PACK:
			debug_label.text = "JET_PACK"
		
		State.ON_WALL:
			debug_label.text = "ON_WALL"
		
		_:
			debug_label.text = "ERROR"
	
	# note: consider move_and_slide_with_snap() if the player goes down ramps
#	_vel_vector.x += walk_input  # consider moving to the state code if needed, could also use a multiplier by state
#	_vel_vector.y += gravity
	velocity.x = lerp(velocity.x, velocity.x + walk_input, walk_force)
	velocity.y = lerp(velocity.y, max_fall_speed, gravity_strength)
	move_and_slide(velocity, Vector2.UP)

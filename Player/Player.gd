extends KinematicBody2D


export var gravity_strength := 10.0
export var max_fall_speed := 300.0
#export var friction_strength := 25.0  # not used right now, friction is based on walk_force

export var walk_force := 25.0
export var max_walk_speed := 200.0

export var jump_strength := 200.0

export var jet_pack_fuel_duration := 1.5
export var jet_pack_thrust_strength := 100.0

var velocity := Vector2.ZERO

enum State {IDLE, RUN, FALL, JUMP, JET_PACK, ON_WALL}
var player_state = State.IDLE

onready var debug_state_label := $debug_state_label
onready var debug_velocity_label := $debug_velocity_label


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	# get input
	var walk_input = Input.get_axis("move_left", "move_right")
	var is_jumping = Input.is_action_pressed("move_jump")
	
	
	# determine state (may have to be done in the state code below)
	
	
	# move player based on state
	# TODO: consider adding floor detect distance
	match player_state:
		State.IDLE:
			debug_state_label.text = "IDLE"
			if ( not is_zero_approx(walk_input) ):# and is_on_floor():
				player_state = State.RUN
			if is_jumping:
				player_state = State.JUMP
		
		State.RUN:
			debug_state_label.text = "RUN"
			if ( is_zero_approx(walk_input) ):# and is_on_floor():
				player_state = State.IDLE
			if is_jumping:
				player_state = State.JUMP
		
		State.FALL:
			debug_state_label.text = "FALL"
			if is_on_floor():
				player_state = State.IDLE
		
		State.JUMP:
			debug_state_label.text = "JUMP"
			if not is_on_floor():
				player_state = State.FALL
			
			velocity.y = -jump_strength
		
		State.JET_PACK:
			debug_state_label.text = "JET_PACK"
		
		State.ON_WALL:
			debug_state_label.text = "ON_WALL"
		
		_:
			debug_state_label.text = "ERROR"
	
	# note: consider move_and_slide_with_snap() if the player goes down ramps
	velocity.x = move_toward(velocity.x, walk_input * max_walk_speed, walk_force)
	velocity.y = move_toward(velocity.y, max_fall_speed, gravity_strength)
	
	debug_velocity_label.text = str(velocity)
	velocity = move_and_slide(velocity, Vector2.UP)

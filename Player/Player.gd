extends KinematicBody2D


var replay_object = null

export var gravity_strength := 10.0
export var max_fall_speed := 300.0
#export var friction_strength := 25.0  # not used right now, friction is based on walk_force instead

export var walk_force := 12.0
export var max_walk_speed := 150.0

export var jump_strength := 150.0

export var jet_pack_fuel_duration := 1.5
export var max_jetpack_speed := 100.0
export var jet_pack_thrust_strength := 60.0

var velocity := Vector2.ZERO

# Note: MUST match States in Replay.gd, consider moving to global/parent class if needed
enum State {IDLE, RUN, FALL, JUMP, JET_PACK, ON_WALL, DEAD}
var player_state = State.IDLE
var is_jumping = false

onready var debug_state_label := $debug_state_label
onready var debug_velocity_label := $debug_velocity_label
onready var debug_misc_label := $debug_misc_label
onready var animation_player := $AnimationPlayer


func kill_player() -> void:
	if player_state != State.DEAD:
		animation_player.play("death")
	player_state = State.DEAD


# should be called from the Orchestrator
func respawn(new_replay_obj, new_spawn_pos) -> void:
	replay_object = new_replay_obj
	player_state = State.IDLE
	position = new_spawn_pos


func _physics_process(_delta: float) -> void:
	###############################################################################################
	# INPUT
	###############################################################################################
	
	var walk_input = Input.get_axis("move_left", "move_right")
	
	# set player to is_jumping manually between press and release, this allows game logic to turn
	# off jumping if needed without inputs overriding game logic. 
	if is_jumping and Input.is_action_just_released("move_jump"):
		is_jumping = false
	elif (not is_jumping) and Input.is_action_just_pressed("move_jump"):
		is_jumping = true
	
	# TODO: TEMPORARY PLAYER ANIMATION LOGIC, EVENTUALLY TIE TO STATES
	if player_state!= State.DEAD:
		if walk_input > 0:
			animation_player.play("fly_forward")
		else:
			animation_player.play("fly_backward")
		
	###############################################################################################
	# STATE MACHINE
	###############################################################################################
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
			if is_jumping:
				player_state = State.JET_PACK
		
		State.JUMP:
			debug_state_label.text = "JUMP"
			if not is_on_floor():
				is_jumping = false
				player_state = State.FALL
			
			velocity.y = -jump_strength
		
		State.JET_PACK:
			debug_state_label.text = "JET_PACK"
			if not is_jumping:
				player_state = State.FALL
			
			velocity.y = move_toward(velocity.y, -max_jetpack_speed, jet_pack_thrust_strength)
		
		State.ON_WALL:
			debug_state_label.text = "ON_WALL"
		
		State.DEAD:
			debug_state_label.text = "DEAD"
		
		_:
			debug_state_label.text = "ERROR"
	
	###############################################################################################
	# MOVEMENT
	###############################################################################################
	# note: consider move_and_slide_with_snap() if the player goes down ramps
	# note: may need to move velocity updates into states themselves, but could also just adjust
	# movement multipliers in each state as appropriate
	
	if player_state == State.DEAD:
		velocity = Vector2.ZERO
	else:
		velocity.x = move_toward(velocity.x, walk_input * max_walk_speed, walk_force)
		velocity.y = move_toward(velocity.y, max_fall_speed, gravity_strength)
	
	debug_velocity_label.text = str(velocity)
	velocity = move_and_slide(velocity, Vector2.UP)
	
	###############################################################################################
	# REPLAY
	###############################################################################################
	replay_object.record_frame(player_state, position)

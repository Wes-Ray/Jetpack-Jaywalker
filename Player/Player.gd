extends KinematicBody2D


onready var new_orchestrator = preload("res://Main.gd")

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

onready var wiper: Sprite = $Wiper
onready var screen_wipe_goal: Position2D = $ScreenWipeGoal
onready var screen_unwipe_goal: Position2D = $ScreenUnwipeGoal
onready var current_screen_goal := screen_unwipe_goal.position

var player_state = new_orchestrator.PlayerStates.IDLE
var is_jumping = false

onready var debug_state_label := $debug_state_label
onready var debug_velocity_label := $debug_velocity_label
onready var debug_misc_label := $debug_misc_label
onready var animation_player := $AnimationPlayer
onready var camera := $Camera2D


func kill_player() -> void:
	if player_state != new_orchestrator.PlayerStates.DEAD:
		animation_player.play("death")
	player_state = new_orchestrator.PlayerStates.DEAD


# should be called from the new_orchestrator
func respawn(new_replay_obj, new_spawn_pos) -> void:
	replay_object = new_replay_obj
	player_state = new_orchestrator.PlayerStates.IDLE
	position = new_spawn_pos


func activate_player() -> void:
	print("activate player")
	player_state = new_orchestrator.PlayerStates.IDLE
	camera.current = true
	screen_unwipe()


func deactivate_player() -> void:
	print("deactivate player")
#	player_state = new_orchestrator.PlayerStates.PAUSED
	screen_wipe()


func screen_wipe() -> void:
	current_screen_goal = screen_wipe_goal.position


func screen_unwipe() -> void:
	current_screen_goal = screen_unwipe_goal.position


func _physics_process(_delta: float) -> void:
	###############################################################################################
	# SCREEN WIPE
	###############################################################################################
	wiper.position = lerp(wiper.position, current_screen_goal, 0.2)
	
	###############################################################################################
	# INPUT
	###############################################################################################
	
	var walk_input = Input.get_axis("move_left", "move_right")
	var current_input : int
	# TODO: TEMPORARY PLAYER ANIMATION LOGIC, EVENTUALLY TIE TO STATES
	if player_state != new_orchestrator.PlayerStates.DEAD:
		if walk_input > 0:
			current_input = new_orchestrator.Inputs.RIGHT
		else:
			current_input = new_orchestrator.Inputs.LEFT
	
	# set player to is_jumping manually between press and release, this allows game logic to turn
	# off jumping if needed without inputs overriding game logic. 
	if is_jumping and Input.is_action_just_released("move_jump"):
		is_jumping = false
	elif (not is_jumping) and Input.is_action_just_pressed("move_jump"):
		is_jumping = true
	
	
		
	###############################################################################################
	# STATE MACHINE
	###############################################################################################
	# TODO: consider adding floor detect distance
	match player_state:
		new_orchestrator.PlayerStates.IDLE:
			debug_state_label.text = "IDLE"
			if ( not is_zero_approx(walk_input) ):# and is_on_floor():
				player_state = new_orchestrator.PlayerStates.RUN
			if is_jumping:
				player_state = new_orchestrator.PlayerStates.JUMP
		
		new_orchestrator.PlayerStates.RUN:
			debug_state_label.text = "RUN"
			if ( is_zero_approx(walk_input) ):# and is_on_floor():
				player_state = new_orchestrator.PlayerStates.IDLE
			if is_jumping:
				player_state = new_orchestrator.PlayerStates.JUMP
		
		new_orchestrator.PlayerStates.FALL:
			debug_state_label.text = "FALL"
			if is_on_floor():
				player_state = new_orchestrator.PlayerStates.IDLE
			if is_jumping:
				player_state = new_orchestrator.PlayerStates.JET_PACK
		
		new_orchestrator.PlayerStates.JUMP:
			debug_state_label.text = "JUMP"
			if not is_on_floor():
				is_jumping = false
				player_state = new_orchestrator.PlayerStates.FALL
			
			velocity.y = -jump_strength
		
		new_orchestrator.PlayerStates.JET_PACK:
			debug_state_label.text = "JET_PACK"
			if not is_jumping:
				player_state = new_orchestrator.PlayerStates.FALL
			
			velocity.y = move_toward(velocity.y, -max_jetpack_speed, jet_pack_thrust_strength)
		
		new_orchestrator.PlayerStates.ON_WALL:
			debug_state_label.text = "ON_WALL"
		
		new_orchestrator.PlayerStates.DEAD:
			debug_state_label.text = "DEAD"
		
		new_orchestrator.PlayerStates.PAUSED:
			debug_state_label.text = "PAUSED"
		
		new_orchestrator.PlayerStates.REACHED_GOAL:
			debug_state_label.text = "REACHED_GOAL"
		
		_:
			debug_state_label.text = "ERROR"
	###############################################################################################
	# ANIMATION
	###############################################################################################
	if player_state != new_orchestrator.PlayerStates.DEAD:
		if current_input == new_orchestrator.Inputs.RIGHT:
			animation_player.play("fly_forward")
		elif current_input == new_orchestrator.Inputs.LEFT:
			animation_player.play("fly_backward")
	
	
	###############################################################################################
	# MOVEMENT
	###############################################################################################
	# note: consider move_and_slide_with_snap() if the player goes down ramps
	# note: may need to move velocity updates into states themselves, but could also just adjust
	# movement multipliers in each state as appropriate
	
	if (player_state == new_orchestrator.PlayerStates.DEAD) \
			or (player_state == new_orchestrator.PlayerStates.PAUSED) \
			or (player_state == new_orchestrator.PlayerStates.REACHED_GOAL):
		velocity = Vector2.ZERO
	else:
		velocity.x = move_toward(velocity.x, walk_input * max_walk_speed, walk_force)
		velocity.y = move_toward(velocity.y, max_fall_speed, gravity_strength)
	
	debug_velocity_label.text = str(velocity)
	velocity = move_and_slide(velocity, Vector2.UP)
	
	###############################################################################################
	# REPLAY
	###############################################################################################
	replay_object.record_frame(player_state, position, current_input)


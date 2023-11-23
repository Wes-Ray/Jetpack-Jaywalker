extends KinematicBody2D


var replay_object = null

enum PlayerStates {IDLE, RUN, FALL, JUMP, JET_PACK, ON_WALL, DEAD, PAUSED, REACHED_GOAL}
enum Inputs {LEFT = 1, RIGHT = 0}

# vertical movement variables
export var jetpack_force := 60.0
export var jump_force := 160.0
export var gravity_strength := 8.0
export var max_jetpack_thrust := 100.0
export var max_fall_speed := 180.0

# lateral movement variables
export var move_force := 10.0
export var drag_force := 1.0
export var max_move_speed := 120.0
export var base_move_speed := 70.0

var velocity := Vector2.ZERO

var inputting := false

onready var wiper: Sprite = $Wiper
onready var screen_wipe_goal: Position2D = $ScreenWipeGoal
onready var screen_unwipe_goal: Position2D = $ScreenUnwipeGoal
onready var current_screen_goal := screen_unwipe_goal.position

#var player_state = Orchestrator.PlayerStates.IDLE
var player_state = PlayerStates.IDLE

onready var debug_state_label := $debug_state_label
onready var debug_velocity_label := $debug_velocity_label
onready var debug_misc_label := $debug_misc_label
onready var animation_player := $AnimationPlayer
onready var camera := $Camera2D


func kill_player() -> void:
	if player_state != PlayerStates.DEAD:
		animation_player.play("death")
	player_state = PlayerStates.DEAD


func set_pos(pos : Vector2) -> void:
	position = pos
	velocity = Vector2.ZERO


# should be called from the Orchestrator
#func respawn(new_replay_obj, new_spawn_pos) -> void:
#	replay_object = new_replay_obj
#	player_state = Orchestrator.PlayerStates.IDLE
#	position = new_spawn_pos


func activate_player() -> void:
	print("activate player")
	player_state = PlayerStates.IDLE
#	camera.current = true
#	screen_unwipe()


func deactivate_player() -> void:
	print("deactivate player")
#	player_state = Orchestrator.PlayerStates.PAUSED
#	screen_wipe()


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
	
	var input_stall = Input.is_action_pressed("move_left")
	var input_forward = Input.is_action_pressed("move_right")
	var inputting = input_forward or input_stall
	var current_input : int
	
	
	# TODO: TEMPORARY PLAYER ANIMATION LOGIC, EVENTUALLY TIE TO STATES
	if player_state != PlayerStates.DEAD:
		if input_forward:
			current_input = Inputs.RIGHT
		else:
			current_input = Inputs.LEFT
	
		
	###############################################################################################
	# STATE MACHINE
	###############################################################################################
	# TODO: consider adding floor detect distance
	match player_state:
		PlayerStates.IDLE:
			debug_state_label.text = "IDLE"
			if ( inputting ):# and is_on_floor():
				player_state = PlayerStates.JET_PACK
		
		PlayerStates.RUN:
			debug_state_label.text = "RUN"
		
		PlayerStates.FALL:
			debug_state_label.text = "FALL"
			if is_on_floor():
				player_state = PlayerStates.IDLE
		
		PlayerStates.JUMP:
			debug_state_label.text = "JUMP"
			
		PlayerStates.JET_PACK:
			debug_state_label.text = "JET_PACK"
			if not inputting:
				player_state = PlayerStates.IDLE
		
		PlayerStates.ON_WALL:
			debug_state_label.text = "ON_WALL"
		
		PlayerStates.DEAD:
			debug_state_label.text = "DEAD"
		
		PlayerStates.PAUSED:
			debug_state_label.text = "PAUSED"
		
		PlayerStates.REACHED_GOAL:
			debug_state_label.text = "REACHED_GOAL"
		
		_:
			debug_state_label.text = "ERROR"
	###############################################################################################
	# ANIMATION
	###############################################################################################
	if player_state != PlayerStates.DEAD:
		if current_input == Inputs.RIGHT:
			animation_player.play("fly_forward")
		elif current_input == Inputs.LEFT:
			animation_player.play("fly_backward")
	
	
	###############################################################################################
	# MOVEMENT
	###############################################################################################
	# note: consider move_and_slide_with_snap() if the player goes down ramps
	# note: may need to move velocity updates into states themselves, but could also just adjust
	# movement multipliers in each state as appropriate
	
	if (player_state == PlayerStates.DEAD) \
			or (player_state == PlayerStates.PAUSED) \
			or (player_state == PlayerStates.REACHED_GOAL):
		velocity = Vector2.ZERO
	else:
		if (player_state == PlayerStates.JET_PACK):
			if input_forward:
				velocity.x = move_toward(velocity.x, max_move_speed, move_force)
			elif input_stall:
				velocity.x = move_toward(velocity.x, 0, move_force)
			if is_on_floor():
				velocity.y -= jump_force
			velocity.y = move_toward(velocity.y, -max_jetpack_thrust, jetpack_force)
		
		# drag simulation
		if velocity.x > base_move_speed:
			velocity.x = move_toward(velocity.x, base_move_speed, drag_force)
		# gravity simulation
		velocity.y = move_toward(velocity.y, max_fall_speed, gravity_strength)
		
		velocity = move_and_slide(velocity, Vector2.UP)
		
	debug_velocity_label.text = str(velocity)
	
	###############################################################################################
	# REPLAY
	###############################################################################################
	# TODO: add back
#	replay_object.record_frame(player_state, position, current_input)


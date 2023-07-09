extends Node2D

# save position coordinates and states for each frame, maybe direction if needed
var state_record := PoolIntArray()
var coord_record := PoolVector2Array()
var input_record := PoolIntArray()

# set to a large number to capture recorded frames
var INITIAL_ARRAY_SIZE = 99999

var current_frame = 0
var death_frame = 0
var recording = true
var replaying = false
var dead = false

onready var debug_misc_label = $debug_misc_label
onready var animation_player = $AnimationPlayer


# note, will have to set all later coords to the same value as when the player is dead
# 	OR: stop updating coords once hitting a DEAD state, but keep player corpse there


func _ready() -> void:
	state_record.resize(INITIAL_ARRAY_SIZE)
	state_record.fill(Orchestrator.PlayerStates.IDLE)
	coord_record.resize(INITIAL_ARRAY_SIZE)  # inits to all Vector2.ZERO
	input_record.resize(INITIAL_ARRAY_SIZE)
	input_record.fill(Orchestrator.Inputs.RIGHT)


func kill_replay(_state = Orchestrator.PlayerStates.DEAD):
#	print("KILL REPLAY")
	
	if not dead:
		animation_player.play("death")
		death_frame = current_frame
	dead = true
	recording = false


func record_frame(state, coord, input) -> void:
	if not recording:
		return
	
	state_record.set(current_frame, state)
	coord_record.set(current_frame, coord)
	input_record.set(current_frame, input)
	
	if (state == Orchestrator.PlayerStates.DEAD) or (state == Orchestrator.PlayerStates.REACHED_GOAL):
		kill_replay(state)
	
	current_frame += 1
	
	if current_frame >= INITIAL_ARRAY_SIZE:
		print("EXCEEDING ARRAY SIZE")


func _physics_process(_delta: float) -> void:
	if not replaying:
		return
	if current_frame >= death_frame:
		return
	
#	match state_record[current_frame]:
#		Orchestrator.PlayerStates.IDLE: 
#			pass
#		Orchestrator.PlayerStates.RUN: 
#			pass
#		Orchestrator.PlayerStates.FALL: 
#			pass
#		Orchestrator.PlayerStates.JUMP: 
#			pass
#		Orchestrator.PlayerStates.JET_PACK: 
#			pass
#		Orchestrator.PlayerStates.ON_WALL: 
#			pass
#		Orchestrator.PlayerStates.DEAD: 
#			pass
#		Orchestrator.PlayerStates.PAUSED: 
#			pass
#		_: 
#			pass
	
	if state_record[current_frame] != Orchestrator.PlayerStates.DEAD:
		if input_record[current_frame] == Orchestrator.Inputs.RIGHT:
			animation_player.play("fly_forward")
		elif input_record[current_frame] == Orchestrator.Inputs.LEFT:
			animation_player.play("fly_backward")
	
	position = coord_record[current_frame]
	
#	debug_misc_label.text = str(position, "\n", current_frame, "\n", death_frame)
	
	current_frame += 1


func replay(start_frame = 0) -> void:
	replaying = true
	current_frame = start_frame
	dead = false
	
	if Orchestrator.is_last_active_replay(self):
		debug_misc_label.text = "LAST ACTIVE"
		$Light2D.enabled = true
	else:
		debug_misc_label.text = "not"
		$Light2D.enabled = false
	
	$AnimationPlayer.play("fly_forward")
	
#	print("replay: ")
#	for i in range(10):
#		print("\t", coord_record[i])

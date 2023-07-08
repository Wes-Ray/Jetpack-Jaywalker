extends Node2D


# Note: MUST match States in Player.gd, consider moving to global/parent class if needed
# States or 0 indexed ints
enum State {IDLE, RUN, FALL, JUMP, JET_PACK, ON_WALL, DEAD}

# save position coordinates and states for each frame, maybe direction if needed
var state_record := PoolIntArray()
var coord_record := PoolVector2Array()

# set to a large number to capture recorded frames
var INITIAL_ARRAY_SIZE = 99999

var current_frame = 0
var death_frame = 0
var recording = true
var _replaying = false

onready var debug_misc_label = $debug_misc_label


# note, will have to set all later coords to the same value as when the player is dead
# 	OR: stop updating coords once hitting a DEAD state, but keep player corpse there


func _ready() -> void:
	state_record.resize(INITIAL_ARRAY_SIZE)
	state_record.fill(State.IDLE)
	coord_record.resize(INITIAL_ARRAY_SIZE)  # inits to all Vector2.ZERO


func record_frame(state, coord) -> void:
	if not recording:
		return

	state_record.set(current_frame, state)
	coord_record.set(current_frame, coord)
	
	if state == State.DEAD:
		death_frame = current_frame
		recording = false
	
	current_frame += 1
	
	if current_frame >= INITIAL_ARRAY_SIZE:
		print("EXCEEDING ARRAY SIZE")


func _physics_process(_delta: float) -> void:
	if not _replaying:
		return
	if current_frame >= death_frame:
		return
	
	position = coord_record[current_frame]
	
	debug_misc_label.text = str(position)
#	debug_misc_label.set_global_position(Vector2(0, 50))
	
	current_frame += 1


func replay(start_frame = 0) -> void:
	_replaying = true
	current_frame = start_frame
	
	print("replay: ")
	for i in range(10):
		print("\t", coord_record[i])

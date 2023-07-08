extends Node2D


# Note: MUST match States in Player.gd, consider moving to global/parent class if needed
# States or 0 indexed ints
enum State {IDLE, RUN, FALL, JUMP, JET_PACK, ON_WALL, DEAD}

# save position coordinates and states for each frame, maybe direction if needed
var state_record := PoolIntArray()
var coord_record := PoolVector2Array()

# 60 fps * 10s = 600 elements, 4x for room (guess)
var INITIAL_ARRAY_SIZE = 2400

var current_frame = 0
var recording = true
var _replaying = false


# note, will have to set all later coords to the same value as when the player is dead
# 	OR: stop updating coords once hitting a DEAD state, but keep player corpse there


func _ready() -> void:
	state_record.resize(INITIAL_ARRAY_SIZE)
	state_record.fill(State.IDLE)
	coord_record.resize(INITIAL_ARRAY_SIZE)  # inits to all Vector2.ZERO
	
	GlobalReplayOrchestrator.register_record_object(self)
	
#	record_frame(State.DEAD, Vector2(2, 3))
#	record_frame(State.IDLE, Vector2(4, 4))


func record_frame(state, coord) -> void:
	if not recording:
		return

	state_record.set(current_frame, state)
	coord_record.set(current_frame, coord)
	current_frame += 1
	
	if state == State.DEAD:
		recording = false

func _physics_process(_delta: float) -> void:
	if not _replaying:
		return
	
	print("coord: ", coord_record[current_frame])
	position = coord_record[current_frame]
	print("\tposition: ", position)
	current_frame += 1


func replay(start_frame = 0) -> void:
	_replaying = true
	current_frame = start_frame
	
	print("replay")
extends Node

# DEBUG PURPOSES
# Note: MUST match States in Replay.gd, consider moving to global/parent class if needed
enum State {IDLE, RUN, FALL, JUMP, JET_PACK, ON_WALL, DEAD}

var record_objects := []
var current_record := 0  # current player saves to this record

# might end up removing this
var player_objects := []

# must be done before a player is registered
func register_record_object(record) -> void:
	print("register record object: ", record)
	record_objects.append(record)


func register_player_to_record(player) -> Node:
	print("register player to record: ", player)
	
	player_objects.append(player)  # more for debug right now
	var ret = record_objects[current_record]
	
	current_record += 1
	if current_record > len(record_objects):
		print("potential error, more players than available records")
	
	return ret


func _physics_process(_delta: float) -> void:
	pass
	
	# DEBUG
	if Input.is_action_just_released("debug1"):
		print("DEBUG 1")
		# test replay
		print("record objects: ", record_objects)
		record_objects[0].replay()
	
	
	if Input.is_action_just_released("debug2"):
		print("DEBUG 2")
		# kill player
		player_objects[0].player_state = State.DEAD
	
	if Input.is_action_just_released("debug3"):
		print("DEBUG 3")
		
		print("record coords: ", record_objects[0].coord_record)

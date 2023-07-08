extends Node

# DEBUG PURPOSES
# Note: MUST match States in Replay.gd, consider moving to global/parent class if needed
enum State {IDLE, RUN, FALL, JUMP, JET_PACK, ON_WALL, DEAD}

var record_objects := []
var current_record := -1  # current player saves to this record

var current_player : KinematicBody2D

const record_preload := preload("res://Replay/Replay.tscn")


func _ready() -> void:
	make_new_record()


func make_new_record() -> void:
	print("make new record")
	
	var new_record = record_preload.instance()
	# might have to update global position to hide spawn
	get_tree().get_current_scene().add_child(new_record)
	record_objects.append(new_record)
	current_record += 1


func register_player(player) -> void:
	current_player = player


func get_current_record() -> Node:
	print("sending current record to player")
	
	return record_objects[current_record]


func apply_damage(area) -> void:
	if area.is_in_group("player"):
		current_player.kill_player()


func replay_all_records() -> void:
	print("replay all records")
	for replay in record_objects:
		replay.replay()


func new_round() -> void:
	print("new round")
	
	make_new_record()
	
	current_player.respawn()


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
		current_player.kill_player()
	
	if Input.is_action_just_released("debug3"):
		print("DEBUG 3")
		
		# start a new round
		new_round()
		
#		print("rec: ", record_objects)
#		print("\trec_len: ", len(record_objects))
		
		replay_all_records()

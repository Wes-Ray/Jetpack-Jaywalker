extends Node

# DEBUG PURPOSES
# Note: MUST match States in Replay.gd, consider moving to global/parent class if needed
enum State {IDLE, RUN, FALL, JUMP, JET_PACK, ON_WALL, DEAD}

var record_objects := []
var current_record := -1  # current player saves to this record

var player : KinematicBody2D
onready var player_spawn_position := Vector2.ZERO

const record_preload := preload("res://Replay/Replay.tscn")
const player_preload := preload("res://Player/Player.tscn")

# entry point: called once the SpawnPosition node first enters the Main scene
func init_spawn_created(spawn : Position2D) -> void:
	player_spawn_position = spawn.position
	print("new spawn position: ", str(spawn.position))
	make_new_player()


func make_new_record() -> void:
	print("make new record")
	
	var new_record = record_preload.instance()
	get_tree().get_current_scene().add_child(new_record)
	record_objects.append(new_record)
	current_record += 1


# should only be called once at the beginning of the game
func make_new_player() -> void:
	print("make new player")
	player = player_preload.instance()
	new_round()
	get_tree().get_current_scene().add_child(player)


func get_current_record() -> Node:
	print("sending current record to player")
	return record_objects[current_record]


func apply_damage(area) -> void:
	if area.is_in_group("player"):
		player.kill_player()


func replay_all_records() -> void:
	print("replay all records")
	for replay in record_objects:
		replay.replay()


func new_round() -> void:
	print("new round")
	
	make_new_record()
	player.respawn(get_current_record(), player_spawn_position)


func _physics_process(_delta: float) -> void:
	pass
	
	# DEBUG
	if Input.is_action_just_released("debug1"):
		print("DEBUG 1")
	
	
	if Input.is_action_just_released("debug2"):
		print("DEBUG 2")
		# kill player
		player.kill_player()
	
	if Input.is_action_just_released("debug3"):
		print("DEBUG 3")
		
		# start a new round
		new_round()
		replay_all_records()

extends Node

# TODO: add signals for replays_complete, etc

# TODO: remove all signals below
signal spawn_player
signal kill_player
signal switch_to_overview
signal switch_to_player_view

onready var replay_timer: Timer = $ReplayTimer  # set tick rate in the inspector
const replay_character_preload := preload("res://Replay2/ReplayCharacter.tscn")

var player : KinematicBody2D
var is_replaying := false
var is_recording := false
# use PoolIntArray()/PoolVector2Array if more speed is needed
var current_pos_data := []
var replay_tick := 0
var replays := []
const POS_OFFSCREEN := Vector2(-400, -400)


func register_player(player_in) -> void:
	player = player_in


#func spawn_player():
#	print("debug spawn player")
#	emit_signal("spawn_player")



#func start_stop_replay():
#	replay_tick = 0
#	is_replaying = not is_replaying
#
#	if is_replaying:
#		print("starting replay")
#	else:
#		print("stopping replay")
#		for r in replays:
#			r.reset()


#func add_replay():
#	print("adding replay")
#	var tmp_replay = replay_character_preload.instance()
#	tmp_replay.init(current_pos_data.duplicate(), POS_OFFSCREEN)
#	get_tree().get_current_scene().add_child(tmp_replay)
#	replays.append(tmp_replay)


#func switch_to_overview():
#	print("switching to overview")
#	emit_signal("switch_to_overview")
#
#
#func switch_to_player_view():
#	print("switching to player view")
#	emit_signal("switch_to_player_view")

func replay() -> void:
	replay_tick = 0
	is_replaying = true

	for r in replays:
		r.reset()


func stop_replay() -> void:
	is_replaying = false


func record() -> void:
	replay_tick = 0
	is_recording = true


func stop_recording_save_replay():
	print("stopping recording, saving current replay")
	var tmp_replay = replay_character_preload.instance()
	tmp_replay.init(current_pos_data.duplicate(), POS_OFFSCREEN)
	get_tree().get_current_scene().add_child(tmp_replay)
	replays.append(tmp_replay)
	current_pos_data = []

	print("ALL REPLAYS:")
	for x in replays:
		print("\t", x)

#func _process(delta: float) -> void:
#	# debug buttons
#	############################################################################
#	if Input.is_action_just_released("debug1"):
#		spawn_player()
#	if Input.is_action_just_pressed("debug2"):
#		start_stop_replay()
#	if Input.is_action_just_pressed("debug3"):
#		switch_to_overview()
#	if Input.is_action_just_pressed("debug4"):
#		switch_to_player_view()
#	if Input.is_action_just_pressed("debug5"):
#		add_replay()


func _on_ReplayTimer_timeout() -> void:

	if is_instance_valid(player) and is_recording:
		current_pos_data.append(player.position)
	
	if is_replaying:
		for r in replays:
			r.replay(replay_tick)
		replay_tick += 1

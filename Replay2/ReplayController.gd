extends Node

signal all_replays_complete

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
	tmp_replay.init(current_pos_data.duplicate(), POS_OFFSCREEN, replay_timer.wait_time)
	get_tree().get_current_scene().call_deferred("add_child", tmp_replay)
	replays.append(tmp_replay)
	current_pos_data = []

	print("ALL REPLAYS:")
	for x in replays:
		print("\t", x)


func _on_ReplayTimer_timeout() -> void:

	if is_instance_valid(player) and is_recording:
		current_pos_data.append(player.position)
	
	if is_replaying:
		is_replaying = false
		for r in replays:
			if r.replay(replay_tick) == true:
				is_replaying = true
		if not is_replaying:
			emit_signal("all_replays_complete")
		replay_tick += 1

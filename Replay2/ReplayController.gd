extends Node2D

signal all_replays_complete

onready var replay_timer: Timer = $ReplayTimer  # set tick rate in the inspector
const replay_character_preload := preload("res://Replay2/ReplayCharacter.tscn")

var defense_active := false

# TODO: replace with actual turret object
const turret_preload := preload("res://Cannon/Cannon.tscn")
var current_turret = null
var TURRET_GROUND_Y_COORD = 425
var TURRET_CEILING_Y_COORD = 225

var player : KinematicBody2D
var is_replaying := false
var is_recording := false
# use PoolIntArray()/PoolVector2Array if more speed is needed
var current_pos_data := []
var current_anim := []
var replay_tick := 0
var replays := []
const POS_OFFSCREEN := Vector2(-400, -400)


func activate_defense():
	defense_active = true

	if current_turret == null:
		current_turret = turret_preload.instance()
		get_tree().get_current_scene().call_deferred("add_child", current_turret)

	replay()


func deactivate_defense():
	defense_active = false
	stop_replay()


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
	tmp_replay.init(current_pos_data.duplicate(), current_anim.duplicate(), POS_OFFSCREEN, replay_timer.wait_time)
	get_tree().get_current_scene().call_deferred("add_child", tmp_replay)
	replays.append(tmp_replay)
	current_pos_data = []
	current_anim = []

	print("ALL REPLAYS:")
	for x in replays:
		print("\t", x)


func _on_ReplayTimer_timeout() -> void:
	if is_instance_valid(player) and is_recording:
		current_pos_data.append(player.position)
		current_anim.append(player.get_node("AnimationPlayer").current_animation)

	if is_replaying:
		is_replaying = false
		for r in replays:
			if r.replay(replay_tick) == true:
				is_replaying = true
		if not is_replaying:
			emit_signal("all_replays_complete")
			deactivate_defense()
		replay_tick += 1


func _physics_process(_delta: float) -> void:
	
	if defense_active:
		if current_turret == null:
			return

		var mouse_pos = get_global_mouse_position()
		current_turret.position.x = mouse_pos.x

		if mouse_pos.y > get_viewport().size.y / 2:
			current_turret.position.y = TURRET_GROUND_Y_COORD
			current_turret.scale.y = 1
		else:
			current_turret.position.y = TURRET_CEILING_Y_COORD
			current_turret.scale.y = -1

		if Input.is_action_just_released("def_place_trap"):
			print("placing trap at: ", current_turret.position)
			current_turret = null


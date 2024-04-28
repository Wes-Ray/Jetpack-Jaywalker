extends Node2D

signal all_replays_complete

onready var replay_timer: Timer = $ReplayTimer  # set tick rate in the inspector
const replay_character_preload := preload("res://Replay/ReplayCharacter.tscn")

var defense_active := false
var round_time := 0.0

# TODO: replace with actual turret object
const turret_preload := preload("res://Turret/Turret.tscn")
var current_turret = null
var turrets := []
var turret_fire_time := []
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


func _physics_process(delta: float) -> void:
	update_turret()
	if defense_active:
		round_time += delta


func activate_defense():
	defense_active = true
	round_time = 0.0

	replay()

	if current_turret == null:
		current_turret = turret_preload.instance()
		# get_tree().get_current_scene().call_deferred("add_child", current_turret)
		# note: if replaycontroller.tscn is place at somewhere other than 0,0 - the turrets will be offset
		add_child(current_turret)
		turrets.append(current_turret)
		turret_fire_time.append(0.0)



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

	for i in range(0, turrets.size()):
		turrets[i].get_node("AnimationPlayer").play("fire")
		turrets[i].get_node("AnimationPlayer").seek(turret_fire_time[i], true)


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


func update_turret():
	if not defense_active:
		return
	
	if current_turret == null:
		return

	# animation update
	if not(current_turret.get_node("AnimationPlayer").is_playing()):
		current_turret.get_node("AnimationPlayer").play("prefire")

	var mouse_pos = get_global_mouse_position()
	current_turret.position.x = mouse_pos.x

	# set turret y position based on snapping thresholds
	if mouse_pos.y > get_viewport().size.y / 2:
		current_turret.position.y = TURRET_GROUND_Y_COORD
		current_turret.scale.y = 1
	else:
		current_turret.position.y = TURRET_CEILING_Y_COORD
		current_turret.scale.y = -1
	current_turret.aim_beam()

	# TODO: fix timing issue (lasers shoot early on replay), print vars and check delta time summation
	if Input.is_action_just_released("def_place_trap"):
		print("placing trap at: ", current_turret.position)
		current_turret.get_node("AnimationPlayer").play("fire")
		# hard coded skip ahead to 1.5 seconds in the animation (fire time)
		current_turret.get_node("AnimationPlayer").seek(1.5, true)
		turret_fire_time.append(fmod(round_time,
			current_turret.get_node("AnimationPlayer").current_animation_length) + 1.5) 
		current_turret = null

func get_last_replay_ref() -> Node2D:
	return replays[-1]

extends Node2D

signal all_replays_complete

onready var replay_timer: Timer = $ReplayTimer  # set tick rate in the inspector
const replay_character_preload := preload("res://Replay/ReplayCharacter.tscn")
const replay_corpse_preload := preload("res://Replay/Corpse.tscn")
const chase_wall_preload := preload("res://ZapWall/ChaseWall.tscn")

var defense_active := false
var offense_active := false
var round_time := 0.0

# TODO: replace with actual turret object
const turret_preload := preload("res://Turret/Turret.tscn")
var current_turret = null
var current_chase_wall = null
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
var active_replay_count := 0  # reflects current active replays, decremented when replays die
const POS_OFFSCREEN := Vector2(-400, -400)


func _physics_process(delta: float) -> void:
	if (defense_active or offense_active):
		round_time += delta
		update_turret()


func activate_defense():
	call_deferred("remove_child", current_chase_wall)
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


func activate_offense():
	# TODO: make wall spawn stuff not ugly
	current_chase_wall = chase_wall_preload.instance()
	call_deferred("add_child", current_chase_wall)
	current_chase_wall.position = get_node("../ChaseWallSpawn").position
	offense_active = true
	round_time = 0.0

	replay()


func deactivate_defense():
	defense_active = false
	stop_replay()


func deactivate_offense():
	offense_active = false
	stop_replay()


func register_player(player_in) -> void:
	player = player_in


func replay() -> void:
	replay_tick = 0
	is_replaying = true
	active_replay_count = len(replays)

	for r in replays:
		r.reset()

	for t in turrets:
		t.reset()	


func stop_replay() -> void:
	is_replaying = false


func record() -> void:
	replay_tick = 0
	is_recording = true


func _connect_replay_signal_to_controller(replay) -> void:
	replay.connect("replay_killed", self, "_on_replay_killed")


func stop_recording_save_replay():
	print("stopping recording, saving current replay")
	var tmp_corpse = replay_corpse_preload.instance()
	var tmp_replay = replay_character_preload.instance()
	tmp_replay.init(current_pos_data.duplicate(), current_anim.duplicate(), POS_OFFSCREEN, replay_timer.wait_time, tmp_corpse)
	# TODO: check if we need to get_tree, or if just call_deferred works
	# get_tree().get_current_scene().call_deferred("add_child", tmp_replay)
	call_deferred("add_child", tmp_corpse)
	call_deferred("add_child", tmp_replay)
	call_deferred("_connect_replay_signal_to_controller", tmp_replay)

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


# TODO: move this into the turret object?
func update_turret():
	if not defense_active:
		return
	
	if current_turret == null:
		return

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

	if Input.is_action_just_released("def_place_trap"):
		print("placing turret at: ", current_turret.position)
		print("Time is: ", round_time / 1000.00)
		current_turret.place(round_time)

		current_turret = null

func get_last_replay_ref() -> Node2D:
	return replays[-1]

func _on_replay_killed() -> void:
	print("REPLAY CONTROLLER SEES REPLAY KILLED")

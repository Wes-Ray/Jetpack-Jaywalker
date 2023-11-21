extends Node

signal spawn_player
signal kill_player
signal switch_to_overview
signal switch_to_player_view

onready var replay_timer: Timer = $ReplayTimer
const replay_character_preload := preload("res://Replay2/ReplayCharacter.tscn")

var player : KinematicBody2D
var is_replaying := false
# use PoolIntArray()/PoolVector2Array if more speed is needed
var pos_data := []  # TODO: expand to more than one player (array of arrays), could also split this up to sub scenes
var replay_tick := 0
var replay : KinematicBody2D  # will have to add to array for multiple replays


func register_player(player_in) -> void:
	player = player_in


func spawn_player():
	print("debug spawn player")
	emit_signal("spawn_player")


#func kill_player():
#	print("debug kill player")
#	emit_signal("kill_player")

func start_replay():
	print("starting replay")
	replay_tick = 0
	replay = replay_character_preload.instance()
	replay.position = pos_data[0]
	get_tree().get_current_scene().add_child(replay)
	is_replaying = true


func switch_to_overview():
	print("switching to overview")
	emit_signal("switch_to_overview")


func switch_to_player_view():
	print("switching to player view")
	emit_signal("switch_to_player_view")


func _process(delta: float) -> void:
	# debug buttons
	############################################################################
	if Input.is_action_just_released("debug1"):
		spawn_player()
	if Input.is_action_just_pressed("debug2"):
		start_replay()
	if Input.is_action_just_pressed("debug3"):
		switch_to_overview()
	if Input.is_action_just_pressed("debug4"):
		switch_to_player_view()


func _on_ReplayTimer_timeout() -> void:
	if player and not is_replaying:
#		print("player pos: ", player.position)
		pos_data.append(player.position)
	
	if is_replaying:
		if replay_tick > pos_data.size() - 1:
			print("END OF REPLAY")
		else:
			print("replaying: ", pos_data[replay_tick])
			replay.position = pos_data[replay_tick]
			replay_tick += 1
	

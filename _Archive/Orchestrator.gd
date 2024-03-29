extends Node

enum PlayerStates {IDLE, RUN, FALL, JUMP, JET_PACK, ON_WALL, DEAD, PAUSED, REACHED_GOAL}
enum Inputs {LEFT = 1, RIGHT = 0}

var record_objects := []
var current_record := -1  # current player saves to this record

var player : KinematicBody2D
onready var player_spawn_position := Vector2.ZERO

var defense : Node2D
var main : Node2D

var global_ui : Label  # round counter
var round_counter := 0

var game_over := false

const record_preload := preload("res://Replay/ReplayCharacter.tscn")
const player_preload := preload("res://Player/Player.tscn")

const splash_preload := preload("res://menu.tscn")

var defense_switch_timer : Timer
var offense_switch_timer : Timer
var game_over_timer : Timer
var replay_delay_timer : Timer

func _ready() -> void:
	
	defense_switch_timer = Timer.new()
	add_child(defense_switch_timer)
	defense_switch_timer.wait_time = 0.7
	defense_switch_timer.one_shot = true
	defense_switch_timer.connect("timeout", self, "_on_defense_timer_timout")
	
	offense_switch_timer = Timer.new()
	add_child(offense_switch_timer)
	offense_switch_timer.wait_time = 0.7
	offense_switch_timer.one_shot = true
	offense_switch_timer.connect("timeout", self, "_on_offense_timer_timout")
	
	game_over_timer = Timer.new()
	add_child(game_over_timer)
	game_over_timer.wait_time = 1.7
	game_over_timer.one_shot = true
	game_over_timer.connect("timeout", self, "_on_game_over_timer_timout")
	
	replay_delay_timer = Timer.new()
	add_child(replay_delay_timer)
	replay_delay_timer.wait_time = .01
	replay_delay_timer.one_shot = true
	replay_delay_timer.connect("timeout", self, "_on_replay_delay_timer_timout")


func is_last_active_replay(replay) -> bool:
#	print("checking last active")
#	print("\t: ", replay)
#	print("\t: ", record_objects[-1])
	
	if replay == record_objects[-1]:
		return true
	return false

# entry point: called once the SpawnPosition node first enters the Main scene
func init_spawn_created(spawn : Position2D) -> void:
	player_spawn_position = spawn.position
	print("new spawn position: ", str(spawn.position))
	make_new_player()


func register_global_UI(ui_in : Label):
	global_ui = ui_in
	incremenent_round()

func incremenent_round():
	round_counter += 1
	global_ui.text = str("Round: ", round_counter)

func register_defense(new_defense : Node2D):
	defense = new_defense
	
func register_main(new_main : Node2D):
	main = new_main


func make_new_record() -> void:
	print("make new record")
	
	var new_record = record_preload.instance()
	get_tree().get_current_scene().add_child(new_record)
	
	new_record.position = Vector2.ZERO
	
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


func all_replays_dead() -> bool:
	for replay in record_objects:
#		print("\t: ", replay.dead)
		if not replay.dead:
			return false
	return true


func _on_game_over_timer_timout():
	print("game over timer timeout")
	player.wiper.visible = false
	defense.wiper.visible = true
	defense.unwipe()
	replay_all_records()
	
	game_over_timer.wait_time = 8
	game_over_timer.start(0)

func end_game(offense_win : bool):
	game_over = true
	player.deactivate_player()
	defense.deactivate_defense()
	defense.reset_defense_camera()
	game_over_timer.start(0)
	main.player_help(false)
	main.defense_help(false)
	main.game_winner(offense_win)
#	defense.camera.current = true
#	defense.wiper.visible = false
#	replay_all_records()


func apply_damage(area) -> void:
	
	if area.is_in_group("player") and \
		(player.player_state != PlayerStates.REACHED_GOAL) and (player.player_state != PlayerStates.PAUSED):
		player.kill_player()
		if game_over == true:
			return
		end_game(false)
	
	if area.is_in_group("replay"):
#		print("REPLAY TOOK DAMAGE")
		area.kill_replay()
		if game_over == true:
			return
		if all_replays_dead():
			print("all replays are dead")
			switch_to_offense()
#		else:
#			print("NOT ALL REPLAYS DEAD")


func goal_entered(area) -> void:
	if game_over == true:
		return
	
	if area.is_in_group("player"):
		# add switch sides logic here
		print("player goal entered")
		player.player_state = PlayerStates.REACHED_GOAL
		switch_to_defense()
	
	if area.is_in_group("replay") and defense.camera.current == true:
		end_game(true)


func _on_defense_timer_timout():
	print("defense timer timed out")
	defense.activate_defense()
	defense.wiper.visible = true
	player.visible = false
	
	
	# TODO: for some reason it only replays runs where the player dies, maybe when reaching the goal
	# I need to make it do the same thing that happens on a death?
#	print(x)
	
	replay_all_records()  # might need to add a timer before starting


func _on_offense_timer_timout():
	print("offense timer timed out")
	player.activate_player()
	player.visible = true
	new_round()
	replay_all_records()
	defense.wiper.visible = false


func switch_to_defense() -> void:
	print("switch to defense")
	
	incremenent_round()
	player.deactivate_player()
	defense_switch_timer.start(0)
	main.player_help(false)
	main.defense_help(true)


func switch_to_offense() -> void:
	print("switch to offense")
	
	incremenent_round()
	defense.deactivate_defense()
#	new_round()
	offense_switch_timer.start(0)
	main.player_help(true)
	main.defense_help(false)


func _on_replay_delay_timer_timout():
	for replay in record_objects:
		replay.replay()

func replay_all_records() -> void:
	print("replay all records")
#	for replay in record_objects:
#		replay.replay()
	replay_delay_timer.start(0)


func new_round() -> void:
	print("new round")
	
	make_new_record()
	player.respawn(get_current_record(), player_spawn_position)


func _physics_process(_delta: float) -> void:
	if game_over:
		defense.strafe_defense_camera()
	
#	if Input.is_action_just_pressed("ui_cancel"):
#		print("reset")
#		get_tree().change_scene_to(splash_preload)
#
#		# reset globals
#		GlobalReset.reset()
#		record_objects = []
#		current_record = -1
#		round_counter = 0
#		game_over = false
#		make_new_player()
	
	# DEBUG
	if Input.is_action_just_released("debug1"):
		print("DEBUG 1")
		if defense.camera.current == true:
			switch_to_offense()
#
#	if Input.is_action_just_released("debug2"):
#		print("DEBUG 2")
#		# kill player
#		switch_to_offense()
#
#	if Input.is_action_just_released("debug3"):
#		print("DEBUG 3")
#
#		# start a new round
#		new_round()
#		replay_all_records()
#
#	if Input.is_action_just_released("debug4"):
#		print("DEBUG 4")
#		player.screen_wipe()
#
#	if Input.is_action_just_released("debug5"):
#		print("DEBUG 5")
#		player.screen_unwipe()
#
#	if Input.is_action_just_released("debug6"):
#		print("DEBUG 6")
#		defense.camera.current = true
	

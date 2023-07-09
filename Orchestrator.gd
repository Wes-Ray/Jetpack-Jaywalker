extends Node

enum PlayerStates {IDLE, RUN, FALL, JUMP, JET_PACK, ON_WALL, DEAD, PAUSED, REACHED_GOAL}
enum Inputs {LEFT = 1, RIGHT = 0}

var record_objects := []
var current_record := -1  # current player saves to this record

var player : KinematicBody2D
onready var player_spawn_position := Vector2.ZERO

var defense : Node2D

var global_ui : Label

const record_preload := preload("res://Replay/Replay.tscn")
const player_preload := preload("res://Player/Player.tscn")

onready var defense_switch_timer : Timer
onready var offense_switch_timer : Timer

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


# entry point: called once the SpawnPosition node first enters the Main scene
func init_spawn_created(spawn : Position2D) -> void:
	player_spawn_position = spawn.position
	print("new spawn position: ", str(spawn.position))
	make_new_player()


func register_global_UI(ui_in : Label):
	global_ui = ui_in


func register_defense(new_defense : Node2D):
	defense = new_defense


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


func apply_damage(area) -> void:
	if area.is_in_group("player"):
		player.kill_player()


func goal_entered(area) -> void:
	print("goal entered")
	if area.is_in_group("player"):
		# add switch sides logic here
#		new_round()
#		replay_all_records()
		player.player_state = PlayerStates.REACHED_GOAL
		switch_to_defense()


func _on_defense_timer_timout():
	print("defense timer timed out")
	defense.activate_defense()
	defense.wiper.visible = true
	player.visible = false
	
	
	# TODO: for some reason it only replays runs where the player dies, maybe when reaching the goal
	# I need to make it do the same thing that happens on a death?
	print(x)
	new_round()
	replay_all_records()  # might need to add a timer before starting


func _on_offense_timer_timout():
	print("offense timer timed out")
	player.activate_player()
	player.visible = true
	defense.wiper.visible = false


func switch_to_defense() -> void:
	print("switch to defense")
	player.deactivate_player()
	defense_switch_timer.start(0)


func switch_to_offense() -> void:
	print("switch to offense")
	defense.deactivate_defense()
	offense_switch_timer.start(0)


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
		switch_to_defense()
	
	if Input.is_action_just_released("debug2"):
		print("DEBUG 2")
		# kill player
		switch_to_offense()
	
	if Input.is_action_just_released("debug3"):
		print("DEBUG 3")
		
		# start a new round
		new_round()
		replay_all_records()
	
	if Input.is_action_just_released("debug4"):
		print("DEBUG 4")
		player.screen_wipe()
	
	if Input.is_action_just_released("debug5"):
		print("DEBUG 5")
		player.screen_unwipe()
	
	if Input.is_action_just_released("debug6"):
		print("DEBUG 6")
	

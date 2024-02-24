extends Node2D

onready var gd_logo = $Sprite

onready var replay_controller: Node = $ReplayController
onready var spawn_position: Position2D = $SpawnPosition
const player_preload := preload("res://Player/Player.tscn")
onready var overview_camera: Camera2D = $OverviewCamera
onready var wiper = $Wiper

var player : KinematicBody2D


func _ready() -> void:
	spawn_player()
	# Orchestrator.init_spawn_created($SpawnPosition)
	# Orchestrator.register_global_UI($UI)
	# Orchestrator.register_main(self)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug6"):
		player.set_pos(spawn_position.position)
	if Input.is_action_just_pressed("debug1"):
		spawn_player()
	if Input.is_action_just_pressed("def_place_trap"):
		# var screen_coord = get_local_mouse_position()
		var screen_coord = get_global_mouse_position() 
		print("screen coord: ", screen_coord)
		gd_logo.position = screen_coord
		overview_camera.wipe_to_target(screen_coord)


func spawn_player() -> void:
	player = player_preload.instance()
	player.position = spawn_position.position
	player.add_to_group("player")

	replay_controller.register_player(player)
	replay_controller.record()

	get_tree().get_current_scene().add_child(player)

	
func _switch_to_defense() -> void:
	print("switching to defense in 0.5")
	# TODO: swap cameras back and forth
	
	# var tween = Tween.new()
	# add_child(tween)
	# tween.interpolate_property(wiper, "shader_param/wipe_amount", 0.0, 1.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	# tween.start()
	


	yield(get_tree().create_timer(0.5), "timeout")
	replay_controller.activate_defense()

func _on_ReplayController_all_replays_complete() -> void:
	print("all replays complete")
	spawn_player()


func player_reached_goal() -> void:
	print("player reached goal")
	replay_controller.stop_recording_save_replay()
	player.call_deferred("free")  # must be done second or it will crash

	_switch_to_defense()
	


#func player_help(on : bool):
#	if on:
#		$PlayerHelp.visible = true
#	else:
#		$PlayerHelp.visible = false
#
#func defense_help(on : bool):
#	if on:
#		$DefenseHelp.visible = true
#	else:
#		$DefenseHelp.visible = false
#
#func game_winner(offense_win : bool):
#	if offense_win:
#		$GameOverOffense.visible = true
#	else:
#		$GameOverDefense.visible = true
#
#
func _on_AttackerGoal_area_entered(area: Area2D) -> void:
#	Orchestrator.goal_entered(area)
	if area.is_in_group("player"):
		player_reached_goal()




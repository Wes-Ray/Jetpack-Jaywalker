extends Node2D

onready var replay_controller: Node = $ReplayController
onready var spawn_position: Position2D = $SpawnPosition
const player_preload := preload("res://Player/Player.tscn")
onready var overview_camera: Camera2D = $OverviewCamera
onready var ui_text: Label = $UI

var player : KinematicBody2D

enum GameState {
	TRANSITION_TO_OFFENSE,
	TRANSITION_TO_DEFENSE,
	OFFENSE,
	DEFENSE,
}
var game_state


func _ready() -> void:
	game_state = GameState.TRANSITION_TO_OFFENSE
	# Orchestrator.init_spawn_created($SpawnPosition)
	# Orchestrator.register_global_UI($UI)
	# Orchestrator.register_main(self)


func _physics_process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	match game_state:
		GameState.TRANSITION_TO_OFFENSE:
			ui_text.text = "TRANSITION TO OFFENSE (space)"
			if Input.is_action_just_pressed("ui_accept"):
				game_state = GameState.OFFENSE
				spawn_player()
				replay_controller.replay()
		GameState.TRANSITION_TO_DEFENSE:
			ui_text.text = "TRANSITION TO DEFENSE (space)"
			if Input.is_action_just_pressed("ui_accept"):
				game_state = GameState.DEFENSE
				replay_controller.activate_defense()
		GameState.OFFENSE:
			ui_text.text = "OFFENSE"
		GameState.DEFENSE:
			ui_text.text = "DEFENSE"


	#
	# debug
	#
	if Input.is_action_just_pressed("debug2"):
		replay_controller.replay()
	if Input.is_action_just_pressed("debug6"):
		player.set_pos(spawn_position.position)
	if Input.is_action_just_pressed("debug1"):
		spawn_player()
	if Input.is_action_just_pressed("def_place_trap"):
		# var screen_coord = get_local_mouse_position()
		var screen_coord = get_global_mouse_position() 
		print("screen coord: ", screen_coord)
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
	game_state = GameState.TRANSITION_TO_DEFENSE


func _on_ReplayController_all_replays_complete() -> void:
	print("all replays complete")
	game_state = GameState.TRANSITION_TO_OFFENSE

	yield(get_tree().create_timer(1.0), "timeout")


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




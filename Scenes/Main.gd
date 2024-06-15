extends Node2D

onready var replay_controller: Node = $ReplayController
onready var spawn_position: Position2D = $SpawnPosition
const player_preload := preload("res://Player/Player.tscn")
onready var overview_camera: Camera2D = $OverviewCamera
onready var ui_text: Label = $UI
const splash_scene = "res://Scenes/Splash.tscn"

var player : KinematicBody2D

enum GameState {
	TRANSITION_TO_OFFENSE,
	TRANSITION_TO_DEFENSE,
	OFFENSE,
	DEFENSE,
	GAME_OVER,
}
var game_state


func _ready() -> void:
	game_state = GameState.TRANSITION_TO_OFFENSE
	# Orchestrator.init_spawn_created($SpawnPosition)
	# Orchestrator.register_global_UI($UI)
	# Orchestrator.register_main(self)


func _physics_process(_delta: float) -> void:
	
	if Input.is_action_just_released("ui_cancel"):
		get_tree().quit()

	match game_state:
		GameState.TRANSITION_TO_OFFENSE:
			ui_text.text = "TRANSITION TO OFFENSE (space)"
			if Input.is_action_just_released("ui_accept"):
				game_state = GameState.OFFENSE
				replay_controller.activate_offense()
				spawn_player()
		GameState.TRANSITION_TO_DEFENSE:
			ui_text.text = "TRANSITION TO DEFENSE (space)"
			if Input.is_action_just_released("ui_accept"):
				game_state = GameState.DEFENSE
				replay_controller.activate_defense()
		GameState.OFFENSE:
			ui_text.text = "OFFENSE"
		GameState.DEFENSE:
			ui_text.text = "DEFENSE"
		GameState.GAME_OVER:
			ui_text.text = "GAME OVER (space to restart)"
			if Input.is_action_just_released("ui_accept"):
				var error = get_tree().change_scene(splash_scene)
				if error != OK:
					print("error changing scene: ", error)

	#
	# debug
	#
	if Input.is_action_just_released("debug2"):
		replay_controller.replay()
	if Input.is_action_just_released("debug6"):
		player.set_pos(spawn_position.position)
	if Input.is_action_just_released("debug1"):
		spawn_player()
	if Input.is_action_just_released("def_place_trap"):
		# var screen_coord = get_local_mouse_position()
		var screen_coord = get_global_mouse_position() 
		print("screen coord: ", screen_coord)
		overview_camera.wipe_to_target(screen_coord)


func spawn_player() -> void:
	player = player_preload.instance()
	player.position = spawn_position.position
	player.add_to_group("player")  # TODO: is this necessary? the area2d is in the group, not sure if this is relevant
	var err = player.connect("player_killed", self, "_on_player_killed")
	if err != OK:
		print("error connecting player: ", err)

	replay_controller.register_player(player)
	replay_controller.record()

	get_tree().get_current_scene().add_child(player)


func _on_player_killed() -> void:
	game_over()

	
func _switch_to_defense() -> void:
	# TODO: swap cameras back and forth
	
	# var tween = Tween.new()
	# add_child(tween)
	# tween.interpolate_property(wiper, "shader_param/wipe_amount", 0.0, 1.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	# tween.start()
		
	game_state = GameState.TRANSITION_TO_DEFENSE


func _on_ReplayController_all_replays_complete() -> void:
	print("all replays complete")
	if game_state == GameState.DEFENSE:
		game_state = GameState.TRANSITION_TO_OFFENSE


func player_reached_goal() -> void:
	print("player reached goal")
	yield(get_tree().create_timer(0.15), "timeout")
	replay_controller.stop_recording_save_replay()
	player.call_deferred("free")  # must be done second or it will crash

	_switch_to_defense()
	

func game_over():
	game_state = GameState.GAME_OVER

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
	print("GOAL ENTERED")
	if area.is_in_group("player"):
		player_reached_goal()
	
	# TODO: sometimes this doesn't trigger, I think it's because the replay doesn't actually enter the goal
	# we should probably just trigger it when the replay ends instead of when it intersects, or we can make
	# the player not despawn instantly when they reach the goal
	if area.is_in_group("replay"):
		print("replay entered goal")
		game_over()




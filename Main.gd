extends Node2D

onready var replay_controller: Node = $ReplayController
onready var spawn_position: Position2D = $SpawnPosition
const player_preload := preload("res://Player/Player.tscn")
onready var camera_2d: Camera2D = $Camera2D

var player : KinematicBody2D

func _ready() -> void:
	pass
#	Orchestrator.init_spawn_created($SpawnPosition)
#	Orchestrator.register_global_UI($UI)
#	Orchestrator.register_main(self)

func _on_ReplayController_spawn_player() -> void:
	player = player_preload.instance()
	player.position = spawn_position.position
	replay_controller.register_player(player)
	get_tree().get_current_scene().add_child(player)


func _on_ReplayController_kill_player() -> void:
	player.free()


func _on_ReplayController_switch_to_overview() -> void:
	camera_2d.current = true


func _on_ReplayController_switch_to_player_view() -> void:
	player.camera.current = true


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
#func _on_AttackerGoal_area_entered(area: Area2D) -> void:
#	Orchestrator.goal_entered(area)


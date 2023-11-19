extends Node

signal spawn_player
signal switch_to_overview
signal switch_to_player_view

onready var replay_timer: Timer = $ReplayTimer

var player : KinematicBody2D


func register_player(player_in) -> void:
	player = player_in


func spawn_player():
	print("debug spawn player")
	emit_signal("spawn_player")


func despawn_player():
	print("debug despawn player")


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
		despawn_player()
	if Input.is_action_just_pressed("debug3"):
		switch_to_overview()
	if Input.is_action_just_pressed("debug4"):
		switch_to_player_view()


func _on_ReplayTimer_timeout() -> void:
	if player:
		print("player pos: ", player.position)
	

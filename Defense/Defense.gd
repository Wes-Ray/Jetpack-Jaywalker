extends Node2D


onready var camera = $Camera2D


func _ready() -> void:
	Orchestrator.register_defense(self)


func activate_defense() -> void:
	camera.current = true


func deactivate_defense() -> void:
	pass

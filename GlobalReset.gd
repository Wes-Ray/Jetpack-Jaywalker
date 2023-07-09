extends Node


func reset() -> void:
	Orchestrator.set_script(null)
	Orchestrator.set_script(preload("res://Orchestrator.gd"))

extends Node2D


func _ready() -> void:
	Orchestrator.init_spawn_created($SpawnPosition)

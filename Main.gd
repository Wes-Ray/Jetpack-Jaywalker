extends Node2D


func _ready() -> void:
	Orchestrator.init_spawn_created($SpawnPosition)
	Orchestrator.register_global_UI($UI)


func _on_AttackerGoal_area_entered(area: Area2D) -> void:
	Orchestrator.goal_entered(area)

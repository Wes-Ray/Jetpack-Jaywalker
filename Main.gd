extends Node2D


func _ready() -> void:
	Orchestrator.init_spawn_created($SpawnPosition)
	Orchestrator.register_global_UI($UI)
	Orchestrator.register_main(self)

func player_help(on : bool):
	if on:
		$PlayerHelp.visible = true
	else:
		$PlayerHelp.visible = false
		
func defense_help(on : bool):
	if on:
		$DefenseHelp.visible = true
	else:
		$DefenseHelp.visible = false
		
func game_winner(offense_win : bool):
	if offense_win:
		$GameOverOffense.visible = true
	else:
		$GameOverDefense.visible = true


func _on_AttackerGoal_area_entered(area: Area2D) -> void:
	Orchestrator.goal_entered(area)
